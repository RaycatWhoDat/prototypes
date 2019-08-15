export enum HTTPMethod {
    GET = 'get',
    POST = 'post',
    PUT = 'put',
    DELETE = 'delete'
}

export interface VaultRoute {
    path: string,
    method: HTTPMethod,
    handler: Function
}

export interface VaultFile {
    _id: string,
    creatorId: string,
    fileName: string,
    fileType: string,
    sourceId?: string,
    firmId?: string
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
    attributes: VaultAttribute[]
}

export interface VaultSource {
    _id: string,
    sourceData: string,
    isEmbeddable: boolean
}
