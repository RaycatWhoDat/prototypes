const filesCollection = db.files;
const relationshipsCollection = db.relationships;
const sourcesCollection = db.sources;
const attributesCollection = db.attributes;

const SEED_SETTINGS = {
    files: 20,
    relationships: 100,
    agreements: 2,
    signatures: 10
};

const baseOperations = {
    files: [],
    relationships: [],
    sources: [],
    attributes: []
};

const allGeneratedFileIds = [];
const allGeneratedAgreementIds = [];

const creatorId = String(Math.floor(Math.random() * 9999999) + 1);
const dateCreated = new Date();

const possibleFileTypes = [
    'text',
    'note',
    'chatroom',
    'message',
    'folder'
];

const possibleSources = [
    'Aliquam erat volutpat.',
    'Nunc eleifend leo vitae magna.',
    'In id erat non orci commodo lobortis.',
    'Proin neque massa, cursus ut, gravida ut, lobortis eget, lacus.',
    'Sed diam.',
    'Praesent fermentum tempor tellus.',
    'Nullam tempus.',
    'Mauris ac felis vel velit tristique imperdiet.',
    'Donec at pede.',
    'Etiam vel neque nec dui dignissim bibendum.',
    'Vivamus id enim.',
    'Phasellus neque orci, porta a, aliquet quis, semper a, massa.',
    'Phasellus purus.',
    'Pellentesque tristique imperdiet tortor.',
    'Nam euismod tellus id erat.',
    'Nullam eu ante vel est convallis dignissim.',
    'Fusce suscipit, wisi nec facilisis facilisis, est dui fermentum leo, quis tempor ligula erat quis odio.',
    'Nunc porta vulputate tellus.',
    'Nunc rutrum turpis sed pede.',
    'Sed bibendum.',
    'Aliquam posuere.',
    'Nunc aliquet, augue nec adipiscing interdum, lacus tellus malesuada massa, quis varius mi purus non odio.',
    'Pellentesque condimentum, magna ut suscipit hendrerit, ipsum augue ornare nulla, non luctus diam neque sit amet urna.',
    'Curabitur vulputate vestibulum lorem.',
    'Fusce sagittis, libero non molestie mollis, magna orci ultrices dolor, at vulputate neque nulla lacinia eros.',
    'Sed id ligula quis est convallis tempor.',
    'Curabitur lacinia pulvinar nibh.',
    'Nam a sapien.',
];
    
const fileNameMapping = {
    'text': 'textFile',
    'note': 'note',
    'chatroom': 'chatroom',
    'message': 'message',
    'folder': 'folder',
    'agreement': 'agreement',
    'signature': 'signature'
};

for (let index = 0; index < SEED_SETTINGS.files; index++) {
    const fileId = new ObjectId();
    allGeneratedFileIds.push(fileId);

    const sourceId = new ObjectId();
    const attributeId = new ObjectId();

    const fileType = possibleFileTypes[Math.floor(Math.random() * (possibleFileTypes.length - 1))];
    const sourceData = possibleSources[Math.floor(Math.random() * (possibleSources.length - 1))];

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
        sourceData,
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

for (let index = 0; index < SEED_SETTINGS.agreements; index++) {
    const fileId = new ObjectId();
    allGeneratedAgreementIds.push(fileId);

    const sourceId = new ObjectId();
    const attributeId = new ObjectId();

    const fileType = 'agreement';
    const sourceData = possibleSources[Math.floor(Math.random() * (possibleSources.length - 1))];
 
    const fileName = `agreement${index + 1}`;
    
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
        sourceData,
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

for (let index = 0; index < SEED_SETTINGS.signatures; index++) {
    const parentId = allGeneratedAgreementIds[Math.floor(Math.random() * allGeneratedAgreementIds.length)];
    const fileId = new ObjectId();

    const sourceId = new ObjectId();
    const attributeId = new ObjectId();

    const fileType = 'signature';
    const sourceData = possibleSources[Math.floor(Math.random() * (possibleSources.length - 1))];
 
    const fileName = `signature${index + 1}`;
    
    const newFile = {
        _id: fileId,
        creatorId,
        fileName,
        fileType,
        dateCreated,
        sourceId
    };

    const newRelationship = {
        parentId,
        fileId,
        ownerId: creatorId,
        permissions: NumberInt(7),
        attributes: [attributeId],
        dateCreated
    };

    const newSource = {
        _id: sourceId,
        sourceData,
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
