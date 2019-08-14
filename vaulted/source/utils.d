module vaulted.utils;

import vibe.data.bson;

Bson wrapBsonAsVaultFile(Bson parsedBson) {
  if (!parsedBson.isNull) parsedBson["fileId"] = parsedBson["_id"];
  return parsedBson;
}
