const currentCollection = db.files;

const numberOfFiles = 10;

const currentOperations = Array(numberOfFiles)
      .fill({})
      .map((_, index) => {
          const emptyFile = {
              fileName: `file${index + 1}.txt`,
              fileType: 'text',
              parentId: new ObjectId(),
              sourceId: new ObjectId(),
              ownerId: NumberInt(Math.floor(Math.random() * 9999999) + 1),
              creatorId: NumberInt(Math.floor(Math.random() * 9999999) + 1),
              permissions: NumberInt(7),
              attributes: [{
                  attributeId: new ObjectId(),
                  attributeName: `attribute${index + 1}`,
                  attributeColor: '#000000'
              }]
          };          
          
          return { insertOne: { document: emptyFile } };
      });

// currentOperations.forEach(printjson);

// Execute.
currentCollection.bulkWrite(currentOperations);

// Local variables for Emacs. 
// Local Variables:
// compile-command: "mongo 127.0.0.1:27017/vault ./seedDB.js"
// End:
