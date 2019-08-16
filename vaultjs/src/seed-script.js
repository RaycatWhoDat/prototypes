const filesCollection = db.files;
const relationshipsCollection = db.relationships;
const sourcesCollection = db.sources;
const attributesCollection = db.attributes;

const SEED_SETTINGS = {
    files: 10,
    relationships: 100
};

const baseOperations = {
    files: [],
    relationships: [],
    sources: [],
    attributes: []
};

const allGeneratedFileIds = [];
// ampfirm.admin@runoranj.com
const creatorId = String(8600941); //String(Math.floor(Math.random() * 9999999) + 1);
const dateCreated = new Date();

    // TEXT = 'text',
    // NOTE = 'note',
    // CHATROOM = 'chatroom',
    // MESSAGE = 'message'
const possibleFileTypes = [
    'text',
    'note',
    'chatroom',
    'message'
];

for (let index = 0; index < SEED_SETTINGS.files; index++) {
    const fileId = new ObjectId();
    allGeneratedFileIds.push(fileId);

    const sourceId = new ObjectId();
    const attributeId = new ObjectId();

    const fileType = possibleFileTypes[Math.floor(Math.random() * 3)];
    const fileNameMapping = {
        'text': 'textFile',
        'note': 'note',
        'chatroom': 'chatroom',
        'message': 'message'
    };

    const fileName = [
        `${fileNameMapping[fileType]}`,
        `${index + 1}`,
        `${fileType === 'text' ? '.txt' : ''}`
    ].join('');
    
    const newFile = {
        _id: fileId,
        creatorId,
        fileName,
        fileType,
        dateCreated,
        sourceId
    };

    const newRelationship = {
        parentId: creatorId,
        fileId,
        ownerId: creatorId,
        permissions: NumberInt(7),
        attributes: [attributeId],
        dateCreated
    };

    const newSource = {
        _id: sourceId,
        sourceData: 'Fusce sagittis, libero non molestie mollis, magna orci ultrices dolor, at vulputate neque nulla lacinia eros.',
        isEmbeddable: true
    };

    const newAttribute = {
        _id: attributeId,
        attributeName: `attribute${index + 1}`,
        attributeColor: '#' + (Math.random() * 0xFFFFFF << 0).toString(16)
    }

    baseOperations.files.push({ insertOne: { document: newFile }});
    baseOperations.relationships.push({ insertOne: { document: newRelationship }});
    baseOperations.sources.push({ insertOne: { document: newSource }});
    baseOperations.attributes.push({ insertOne: { document: newAttribute }});
}

for (let index = 0; index < SEED_SETTINGS.relationships - SEED_SETTINGS.files; index++) {
    const parentId = allGeneratedFileIds[Math.floor(Math.random() * allGeneratedFileIds.length)];
    const fileId = allGeneratedFileIds[Math.floor(Math.random() * allGeneratedFileIds.length)];
    
    const newRelationship = {
        parentId,
        fileId,
        ownerId: creatorId,
        permissions: NumberInt(7),
        attributes: [],
        dateCreated
    };
    
    baseOperations.relationships.push({ insertOne: { document: newRelationship }});
}

// currentOperations.forEach(printjson);

// Execute.
filesCollection.bulkWrite(baseOperations.files);
relationshipsCollection.bulkWrite(baseOperations.relationships);
sourcesCollection.bulkWrite(baseOperations.sources);
attributesCollection.bulkWrite(baseOperations.attributes);

// Local variables for Emacs. 
// Local Variables:
// compile-command: "mongo 127.0.0.1:27017/vault ./seed-script.js"
// End:
