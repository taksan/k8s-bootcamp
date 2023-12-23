curl -u 'storeuser:storepass' http://store.dev.cimple.bootcamp/items | jq -r "keys[]" | xargs -I{} curl -u 'storeuser:storepass' -X DELETE http://store.dev.cimple.bootcamp/items/\{\}
