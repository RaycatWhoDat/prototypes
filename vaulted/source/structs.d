module vaulted.structs;

struct VaultFileData {
  string fileId;
  string fileName;
  int creatorId;
  string fileType;
  string sourceId;
  string firmId;
}

struct Source {
  string sourceId;
  string data;
  bool isEmbeddable;
}

struct Attribute {
  string attributeId;
  string attributeName;
  string attributeColor;
}

struct Relationship {
  string relationshipId;
  string parentId;
  string fileId;
  int permissions;
  Attribute[] attributes;
  int ownerId;
}

struct VaultFile {
  string fileId;
  string fileName;
  string fileType;
  string parentId;
  string sourceId;
  int ownerId;
  int creatorId;
  int permissions;
  Attribute[] attributes;
}
