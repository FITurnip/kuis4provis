const String baseUrl = '192.168.100.36:8000/';
Uri usersUri(int? userId) {
  return Uri.parse('${baseUrl}users/${userId.toString()}');
}

Uri loginUri() {
  return Uri.parse('${baseUrl}login/');
}

Uri cartsUri(int? userId) {
  return Uri.parse('${baseUrl}carts/');
}

Uri itemsUri() {
  return Uri.parse('${baseUrl}items/');
}

Uri clearWholeCartsUri(int userId) {
  return Uri.parse(baseUrl + userId.toString());
}

Uri itemsImageUri(int itemId) {
  return Uri.parse('${baseUrl}items_image/${itemId.toString()}');
}

Uri searchItemsUri(String keyword) {
  return Uri.parse('${baseUrl}search_items/${keyword}');
} 

Uri tokenUri() {
  return Uri.parse('${baseUrl}token/');
}
