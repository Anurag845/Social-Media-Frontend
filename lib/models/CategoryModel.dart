class CategoryModel {
  int categoryId;
  String categoryName;
  String categoryImage;

  CategoryModel(this.categoryId, this.categoryName, this.categoryImage);

  CategoryModel.fromJson(Map<String, dynamic> map) :
    categoryId = map["category_id"],
    categoryName = map["category_name"],
    categoryImage = map["category_image"];
}