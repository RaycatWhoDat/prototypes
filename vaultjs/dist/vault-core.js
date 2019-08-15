"use strict";
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
var mongodb_1 = require("mongodb");
var lodash_1 = require("lodash");
var express = require('express');
var cors = require('cors');
var bodyParser = __importStar(require("body-parser"));
// Server setup
var DEFAULT_PORT = 8080;
var MONGODB_URL = 'mongodb://localhost:27017';
var MONGODB_DATABASE_NAME = 'vault';
var MONGODB_CLIENT_OPTIONS = {
    useNewUrlParser: true,
    useUnifiedTopology: true
};
var server = express();
server.set('port', process.env.PORT || DEFAULT_PORT);
var port = server.get('port');
server.use(cors());
server.use(express.static('dist'));
var jsonParser = bodyParser.json();
var client = new mongodb_1.MongoClient(MONGODB_URL, MONGODB_CLIENT_OPTIONS);
client.connect(function (error) {
    if (error) {
        console.log('MongoDB failed to connect.');
        return;
    }
    console.log('MongoDB connected.');
    var database = client.db(MONGODB_DATABASE_NAME);
    server.get('/files/list/:fileId', listFiles(database));
    server.get('/files/fetch/:fileId', getFile(database));
    server.get('/attributes/list/:fileId', getAttributes(database));
    server.post('/files/copy/:fileId', jsonParser, copyFile(database));
    server.put('/files/update/:fileId', jsonParser, updateFile(database));
    server.delete('/files/delete/:fileId', jsonParser, deleteFile(database));
    server.listen(port, rootHandler);
});
// Functions
var rootHandler = function () { return console.log("Vault running on " + port + "!"); };
var validObjectIdRegex = new RegExp("^[0-9a-fA-F]{24}$");
var isValidObjectId = function (objectId) { return validObjectIdRegex.test(objectId); };
var listFiles = function (database) { return function (request, response) {
    var relationshipsCollection = database.collection('relationships');
    var parentId = lodash_1.get(request, ['params', 'fileId'], null);
    parentId = isValidObjectId(parentId)
        ? new mongodb_1.ObjectId(parentId)
        : parentId;
    if (lodash_1.isNil(parentId))
        return response.status(404).send();
    var fullFilePipeline = [
        {
            $match: { parentId: parentId }
        }, {
            $lookup: {
                'from': 'files',
                'localField': 'fileId',
                'foreignField': '_id',
                'as': 'fileInformation'
            }
        }, {
            $unwind: '$fileInformation'
        }, {
            $lookup: {
                'from': 'sources',
                'localField': 'fileInformation.sourceId',
                'foreignField': '_id',
                'as': 'sourceInformation'
            }
        }, {
            $unwind: '$sourceInformation'
        }, {
            $project: {
                '_id': 0,
                'fileId': 1,
                'fileName': '$fileInformation.fileName',
                'fileType': '$fileInformation.fileType',
                'parentId': 1,
                'source': '$sourceInformation.sourceData',
                'ownerId': 1,
                'creatorId': '$fileInformation.creatorId',
                'permissions': 1,
                'attributes': 1,
                'isEmbeddable': '$sourceInformation.isEmbeddable'
            }
        }
    ];
    relationshipsCollection
        .aggregate(fullFilePipeline)
        .toArray(function (_, allFiles) {
        response.json(allFiles);
    });
}; };
var getFile = function (database) { return function (request, response) {
    var filesCollection = database.collection('files');
    var _id = lodash_1.get(request, ['params', 'fileId'], null);
    _id = isValidObjectId(_id)
        ? new mongodb_1.ObjectId(_id)
        : _id;
    if (lodash_1.isNil(_id))
        return response.status(404).send();
    var partialFilePipeline = [
        {
            $match: { _id: _id }
        }, {
            $lookup: {
                from: 'sources',
                localField: 'sourceId',
                foreignField: '_id',
                as: 'sourceInformation'
            }
        }, {
            $unwind: '$sourceInformation'
        }, {
            $project: {
                '_id': 0,
                'fileId': '$_id',
                'fileName': 1,
                'fileType': 1,
                'source': '$sourceInformation.sourceData',
                'ownerId': 1,
                'creatorId': 1,
                'attributes': 1,
                'isEmbeddable': '$sourceInformation.isEmbeddable'
            }
        }
    ];
    filesCollection
        .aggregate(partialFilePipeline)
        .toArray(function (_, selectedFile) {
        response.json(selectedFile);
    });
}; };
var updateFile = function (database) { return function (request, response) {
    var rawPayload = lodash_1.get(request, ['body'], {});
    if (lodash_1.isEmpty(rawPayload))
        return response.status(304).send();
    var validKeys = [
        'fileName',
        'fileType',
        'sourceId',
        'creatorId'
    ];
    var formattedPayload = Object.keys(rawPayload)
        .reduce(function (_formattedPayload, keyName) {
        if (validKeys.includes(keyName))
            _formattedPayload[keyName] = rawPayload[keyName];
        return _formattedPayload;
    }, {});
    if (lodash_1.isEmpty(formattedPayload))
        return response.status(304).send();
    var filesCollection = database.collection('files');
    var _id = lodash_1.get(request, ['params', 'fileId'], null);
    filesCollection
        .updateOne({ _id: _id }, { '$set': formattedPayload })
        .then(function (_) {
        response.status(202).send();
    }, function (error) {
        console.error(error);
        response.status(500).send();
    });
}; };
var copyFile = function (database) { return function (request, response) {
    var rawPayload = lodash_1.get(request, ['body'], {});
    var userId = rawPayload.userId, _a = rawPayload.ownerId, ownerId = _a === void 0 ? userId : _a, _b = rawPayload.permissions, permissions = _b === void 0 ? 7 : _b, _c = rawPayload.attributes, attributes = _c === void 0 ? [] : _c;
    if (lodash_1.isEmpty(rawPayload) || !userId)
        return response.status(304).send();
    var fileId = lodash_1.get(request, ['params', 'fileId'], null);
    var formattedPayload = {
        parentId: userId,
        fileId: fileId,
        ownerId: ownerId,
        permissions: permissions,
        attributes: attributes
    };
    var relationshipsCollection = database.collection('relationships');
    relationshipsCollection.insertOne(formattedPayload).then(function (_) {
        response.status(201).send();
    }, function (error) {
        console.error(error);
        response.status(500).send();
    });
}; };
var deleteFile = function (database) { return function (request, response) {
    var relationshipsCollection = database.collection('relationships');
    var selectedId = new mongodb_1.ObjectId(request.params.fileId) || null;
    if (!selectedId)
        return response.status(304).send();
    var deleteOperation = {
        deleteMany: {
            'filter': {
                $or: [
                    { parentId: selectedId },
                    { fileId: selectedId }
                ]
            }
        }
    };
    relationshipsCollection
        .bulkWrite([deleteOperation])
        .then(function (_) {
        response.status(200).send();
    }, function (error) {
        console.error(error);
        response.status(500).send();
    });
}; };
var getAttributes = function (database) { return function (request, response) {
    var relationshipsCollection = database.collection('relationships');
    var fileId = new mongodb_1.ObjectId(request.params.fileId) || null;
    if (!fileId)
        return response.status(304).send();
    var attributePipeline = [
        {
            $match: { fileId: fileId }
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
        .toArray(function (_, allFiles) {
        response.json(allFiles);
    });
}; };
