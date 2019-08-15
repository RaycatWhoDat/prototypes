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
const creatorId = NumberInt(Math.floor(Math.random() * 9999999) + 1);

for (let index = 0; index < SEED_SETTINGS.files; index++) {
    const fileId = new ObjectId();
    allGeneratedFileIds.push(fileId);

    const sourceId = new ObjectId();
    const attributeId = new ObjectId();
    
    const newFile = {
        _id: fileId,
        creatorId,
        fileName: `testFile${index + 1}.txt`,
        fileType: 'text'
    };

    if (Math.random() < 0.8) newFile.sourceId = sourceId;
    
    const newRelationship = {
        parentId: creatorId,
        fileId,
        ownerId: creatorId,
        permissions: NumberInt(7),
        attributes: [attributeId]
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
        attributes: []
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
