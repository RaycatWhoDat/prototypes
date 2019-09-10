export interface VaultFile {
    _id: string,
    creatorId: string,
    fileName: string,
    fileType: string,
    sourceId?: string,
    firmId?: string,
    dateCreated: number
}

export interface VaultAttribute {
    _id: string,
    attributeName: string,
    attributeColor: string
}

export interface VaultRelationship {
    _id: string,
    parentId: string | number,
    fileId: string,
    ownerId: string,
    permissions: number,
    attributes: VaultAttribute[],
    dateCreated: number
}

export interface VaultSource {
    _id: string,
    sourceData: string,
    isEmbeddable: boolean
}

export const generateFullFilePipeline = (additionalOperations: any | any[] = []) => {
    const _additionalOperations = Array.isArray(additionalOperations)
        ? additionalOperations
        : [additionalOperations];

    return _additionalOperations.concat([
        {
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
                'dateCreated': {
                    $subtract: [
                        "$fileInformation.dateCreated",
                        new Date("1970-01-01")
                    ]
                },
                'parentId': 1,
                'sourceId': '$fileInformation.sourceId',
                'ownerId': 1,
                'creatorId': '$fileInformation.creatorId',
                'permissions': 1,
                'attributes': 1,
                'isEmbeddable': '$sourceInformation.isEmbeddable'
            }
        }
    ]);
};

export const generateFullFileWithSourcesPipeline = (additionalOperations: any | any[] = []) => {
    const _additionalOperations = Array.isArray(additionalOperations)
        ? additionalOperations
        : [additionalOperations];

    return _additionalOperations.concat([
        {
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
                'dateCreated': {
                    $subtract: [
                        "$fileInformation.dateCreated",
                        new Date("1970-01-01")
                    ]
                },
                'parentId': 1,
                'source': '$sourceInformation.sourceData',
                'ownerId': 1,
                'creatorId': '$fileInformation.creatorId',
                'permissions': 1,
                'attributes': 1,
                'isEmbeddable': '$sourceInformation.isEmbeddable'
            }
        }
    ]);
};

export const generatePartialFilePipeline = (additionalOperations: any | any[] = []) => {
    const _additionalOperations = Array.isArray(additionalOperations)
        ? additionalOperations
        : [additionalOperations];

    return _additionalOperations.concat([
        {
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
                'dateCreated': 1,
                'ownerId': 1,
                'creatorId': 1,
                'attributes': 1,
                'isEmbeddable': '$sourceInformation.isEmbeddable'
            }
        }
    ]);
};
