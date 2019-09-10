import { Request, Response } from 'express';
import { VaultFile, generateFullFilePipeline, generatePartialFilePipeline, generateFullFileWithSourcesPipeline } from './vault-constants';
import { Db, MongoClient, ObjectId } from 'mongodb';
import { get, isNil, isEmpty } from 'lodash';

const express = require('express');
const cors = require('cors');
import * as bodyParser from 'body-parser';

// Server setup

const DEFAULT_PORT = 8080;
const MONGODB_URL = 'mongodb://localhost:27017';
const MONGODB_DATABASE_NAME = 'vault';
const MONGODB_CLIENT_OPTIONS = {
    useNewUrlParser: true,
    useUnifiedTopology: true
};

const server = express();
server.set('port', process.env.PORT || DEFAULT_PORT);
const port = server.get('port');

server.use(cors());
server.use(express.static('dist'));

const jsonParser = bodyParser.json();

const client = new MongoClient(MONGODB_URL, MONGODB_CLIENT_OPTIONS);
client.connect((error: any) => {
    if (error) {
        console.log('MongoDB failed to connect.');
        return;
    }

    console.log('MongoDB connected.');
    const database = client.db(MONGODB_DATABASE_NAME);

    server.get('/files/list/:fileId', listFiles(database));
    server.get('/files/fetch/:fileId', getFile(database));
    server.get('/files/search/:searchTerm', searchFiles(database));
    server.get('/attributes/list/:fileId', getAttributes(database));

    server.get('/files/sources/:fileId', getAllNotes(database));

    server.post('/files/create/:fileId', jsonParser, createFile(database));
    server.post('/files/copy/:fileId', jsonParser, copyFile(database));

    server.put('/files/update/:fileId', jsonParser, updateFile(database));

    server.delete('/files/delete/:fileId', jsonParser, deleteFile(database));

    server.listen(port, () => console.log(`Vault running on ${port}!`));
});

// Functions

const validObjectIdRegex = new RegExp("^[0-9a-fA-F]{24}$");
const isValidObjectId = (objectId: string) => validObjectIdRegex.test(objectId);

const listFiles = (database: Db) => (request: Request, response: Response) => {
    const relationshipsCollection = database.collection('relationships');
    let parentId = get(request, ['params', 'fileId'], null);
    parentId = isValidObjectId(parentId)
        ? new ObjectId(parentId)
        : parentId;

    if (isNil(parentId)) return response.status(404).send();

    const matchOperation = {
        $match: { parentId }
    };

    relationshipsCollection
        .aggregate(generateFullFilePipeline(matchOperation))
        .toArray((_, allFiles: any[]) => {
            response.json(allFiles);
        });
};

const getFile = (database: Db) => (request: Request, response: Response) => {
    const filesCollection = database.collection('files');
    let _id = get(request, ['params', 'fileId'], null);
    _id = isValidObjectId(_id)
        ? new ObjectId(_id)
        : _id;

    if (isNil(_id)) return response.status(404).send();

    const matchOperation = {
        $match: { _id }
    };

    filesCollection
        .aggregate(generatePartialFilePipeline(matchOperation))
        .toArray((_, selectedFile: Partial<VaultFile>[]) => {
            response.json(selectedFile);
        });
};

const updateFile = (database: Db) => (request: Request, response: Response) => {
    const rawPayload = get(request, ['body'], {});
    if (isEmpty(rawPayload)) return response.status(304).send();

    const validKeys = [
        'fileName',
        'fileType',
        'sourceId',
        'creatorId'
    ];

    const formattedPayload: Partial<VaultFile> = Object.keys(rawPayload)
        .reduce((_formattedPayload: any, keyName: string) => {
            if (validKeys.includes(keyName)) _formattedPayload[keyName] = rawPayload[keyName];
            return _formattedPayload;
        }, {});

    if (isEmpty(formattedPayload)) return response.status(304).send();

    const filesCollection = database.collection('files');
    let _id = get(request, ['params', 'fileId'], null);
    _id = isValidObjectId(_id)
        ? new ObjectId(_id)
        : _id;

    filesCollection
        .updateOne({ _id }, { '$set': formattedPayload })
        .then(result => {
            response.status(202).send();
        }, error => {
            console.error(error);
            response.status(500).send();
        });
};

const copyFile = (database: Db) => (request: Request, response: Response) => {
    const rawPayload = get(request, ['body'], {});

    const {
        userId,
        ownerId = userId,
        permissions = 7,
        attributes = []
    } = rawPayload;

    if (isEmpty(rawPayload) || !userId) return response.status(304).send();

    const fileId = get(request, ['params', 'fileId'], null);
    const formattedPayload = {
        parentId: userId,
        fileId,
        ownerId,
        permissions,
        attributes
    };

    const relationshipsCollection = database.collection('relationships');
    relationshipsCollection.insertOne(formattedPayload).then(_ => {
        response.status(201).send();
    }, error => {
        console.error(error);
        response.status(500).send();
    });
};

const deleteFile = (database: Db) => (request: Request, response: Response) => {
    const relationshipsCollection = database.collection('relationships');
    const selectedId = new ObjectId(request.params.fileId) || null;

    if (!selectedId) return response.status(304).send();

    const deleteOperation = {
        deleteMany: {
            filter: {
                $or: [
                    { parentId: selectedId },
                    { fileId: selectedId }
                ]
            }
        }
    };

    relationshipsCollection
        .bulkWrite([deleteOperation])
        .then(_ => {
            response.status(200).send();
        }, error => {
            console.error(error);
            response.status(500).send();
        });
};

const getAttributes = (database: Db) => (request: Request, response: Response) => {
    const relationshipsCollection = database.collection('relationships');
    const fileId = new ObjectId(request.params.fileId) || null;

    if (!fileId) return response.status(304).send();

    const attributePipeline = [
        {
            $match: { fileId }
        }, {
            $unwind: '$attributes'
        }, {
            $lookup: {
                'from': 'attributes',
                'localField': 'attributes',
                'foreignField': '_id',
                'as': 'attributeInformation'
            }
        }, {
            $unwind: '$attributeInformation'
        }, {
            $project: {
                '_id': 0,
                'attributeId': '$attributeInformation._id',
                'attributeName': '$attributeInformation.attributeName',
                'attributeColor': '$attributeInformation.attributeColor'
            }
        }
    ];

    relationshipsCollection
        .aggregate(attributePipeline)
        .toArray((_, allFiles: any[]) => {
            response.json(allFiles);
        });
};

const searchFiles = (database: Db) => (request: Request, response: Response) => {
    const filesCollection = database.collection('files');
    const searchTerm = get(request, ['params', 'searchTerm'], null);

    if (isNil(searchTerm)) return response.status(404).send();

    const matchOperation = {
        $match: {
            'fileName': {
                $regex: searchTerm,
                $options: 'i'
            }
        }
    }

    filesCollection
        .aggregate(generatePartialFilePipeline(matchOperation))
        .toArray((_, allFiles: any[]) => {
            response.json(allFiles);
        });
};

const createFile = (database: Db) => async (request: Request, response: Response) => {
    const filesCollection = database.collection('files');
    const relationshipsCollection = database.collection('relationships');
    const sourcesCollection = database.collection('sources');

    let parentId = get(request, ['params', 'fileId'], null);
    parentId = isValidObjectId(parentId)
        ? new ObjectId(parentId)
        : parentId;

    const rawPayload = get(request, ['body'], {});

    if (isNil(rawPayload) || !rawPayload.source || !rawPayload.creatorId) {
        return response.status(400).send();
    }

    const fileName = rawPayload.fileName || `newFile-${Date.now()}`;
    const fileType = rawPayload.fileType || 'text';
    const creatorId = rawPayload.creatorId;
    const dateCreated = new Date();
    const sourceData = rawPayload.source;
    const isEmbeddable = rawPayload.isEmbeddable || false;

    sourcesCollection
        .insertOne({ sourceData, isEmbeddable })
        .then(result => {
            const newFile = {
                creatorId,
                fileName,
                fileType,
                dateCreated,
                sourceId: result.insertedId
            };

            filesCollection
                .insertOne(newFile)
                .then(result => {
                    const newRelationship = {
                        parentId,
                        fileId: result.insertedId,
                        ownerId: creatorId,
                        permissions: 7,
                        attributes: [],
                        dateCreated
                    };

                    relationshipsCollection
                        .insertOne(newRelationship)
                        .then(_ => {
                            response.status(200).send();
                        }, error => {
                            console.error(error);
                            response.status(500).send();
                        });
                }, error => {
                    console.error(error);
                });

        }, error => {
            console.error(error);
        });
};

const getAllNotes = (database: Db) => async (request: Request, response: Response) => {
    const relationshipsCollection = database.collection('relationships');
    let parentId = get(request, ['params', 'fileId'], null);
    parentId = isValidObjectId(parentId)
        ? new ObjectId(parentId)
        : parentId;

    if (isNil(parentId)) return response.status(404).send();

    const matchOperation = {
        $match: { parentId }
    };

    relationshipsCollection
        .aggregate(generateFullFileWithSourcesPipeline(matchOperation))
        .toArray((_, allFiles: any[]) => {
            response.json(allFiles);
        });
};
