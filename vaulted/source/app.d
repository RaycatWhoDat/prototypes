import std.stdio;
import std.functional;
import std.container;
import std.variant;

import vibe.d;
import vaulted.structs;
import vaulted.utils;

MongoClient client;

void main() {
  auto router = new URLRouter;
  router.registerWebInterface(new APIInterface);

  auto settings = new HTTPServerSettings;
  settings.port = 8080;

  client = connectMongoDB("127.0.0.1/vault", 27017);
  scope(exit) client = null;
  
  listenHTTP(settings, router);
  runApplication();
}

class APIInterface {
  @method(HTTPMethod.GET)
  @path("files/list/:fileId")
  void listFiles(HTTPServerRequest request, HTTPServerResponse response) {
    auto fileCollection = client.getCollection("vault.files");
    BsonObjectID parentId = BsonObjectID.fromString(request.params["fileId"]);
    VaultFile[] allFiles;
    
    foreach (file; fileCollection.find(["parentId": parentId])) {
      VaultFile vaultFile = file
                            .wrapBsonAsVaultFile()
                            .toJson()
                            .deserializeJson!VaultFile();
      
      logInfo("%s: %s", vaultFile.fileId, vaultFile.fileName);
      allFiles ~= vaultFile;
    }
    
    response.writeBody(allFiles.serializeToJsonString(), 200, "application/json");
  }

  @method(HTTPMethod.GET)
  @path("files/fetch/:fileId")
  void fetchFile(HTTPServerRequest request, HTTPServerResponse response) {
    auto fileCollection = client.getCollection("vault.files");
    BsonObjectID fileId = BsonObjectID.fromString(request.params["fileId"]);
    VaultFile[] allFiles = [];
    auto selectedFile = fileCollection.findOne(["_id": fileId]);
    
    if (!selectedFile.isNull) {
      allFiles ~= selectedFile
                  .wrapBsonAsVaultFile()
                  .toJson()
                  .deserializeJson!VaultFile();
    }
    
    response.writeBody(allFiles.serializeToJsonString(), 200, "application/json");
  }

  // TODO: Make this a batch endpoint later on.
  // @method(HTTPMethod.POST)
  // @path("files/update/name/:fileId")
  // void renameFile(HTTPServerRequest request, HTTPServerResponse response, string fileName) {
  //   auto fileCollection = client.getCollection("vault.files");
  //   string fileId = request.params["fileId"];
  //   fileCollection.update(["_id", fileId], ["$set": ["fileName": fileName]]);
  //   response.writeVoidBody();
  // }
  
  // void updateFile(HTTPServerRequest request, HTTPServerResponse response, string key, Variant value) {
    // BsonObjectID fileId = BsonObjectID.fromString(request.params["fileId"]);
  //   string fileId = request.params["fileId"];
  //   fileCollection.update(["_id", fileId], Bson(["$set": Bson([key.makeKey: value.get!Bson])]));
  //   response.writeVoidBody();
  // }
}
