import std.stdio;
import std.functional;
import std.container;
import vibe.d;

struct FileData {
  string fileId;
  string fileName;
  int creatorId;
  string fileType;
  string sourceId;
  string firmId;
}

struct Relationship {
  string relationshipId;
  string parentId;
  string fileId;
  int permissions;
  Attribute[] attributes;
  int ownerId;
}

struct Attribute {
  string attributeId;
  string attributeName;
  string attributeColor;
}

struct Source {
  string sourceId;
  string data;
  bool isEmbeddable;
}

struct File {
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

// interface VaultAPI {}

MongoClient client;

class APIInterface {
  @method(HTTPMethod.GET) @path("/")
  void rootHandler(HTTPServerRequest request, HTTPServerResponse response) {
    response.writeBody("Root route reached.");
  }

  @method(HTTPMethod.GET) @path("files/:parentId")
  void getFiles(HTTPServerRequest request, HTTPServerResponse response) {
    Bson[] allFiles;
    auto fileCollection = client.getCollection("vault.files");
    foreach (file; fileCollection.find()) {
      logInfo("Found: %s", file["fileName"]);
      allFiles ~= file;
    }
    
    response.writeBody(allFiles.serializeToJsonString(), 200, "application/json");
  }
}

void routeNotFound(HTTPServerRequest request, HTTPServerResponse response, HTTPServerErrorInfo error) {
  response.writeBody("Route not found.");
}
  
void main() {
  auto router = new URLRouter;
  router.registerWebInterface(new APIInterface);

  auto settings = new HTTPServerSettings;
  settings.port = 8080;
  settings.errorPageHandler = toDelegate(&routeNotFound);

  client = connectMongoDB("127.0.0.1/vault", 27017);
  scope(exit) client = null;
  
  listenHTTP(settings, router);
  runApplication();
}
