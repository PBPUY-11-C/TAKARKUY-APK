import 'dart:convert';

List<Recipe> recipeFromJson(String str) =>
    List<Recipe>.from(json.decode(str).map((x) => Recipe.fromJson(x)));

String recipeToJson(List<Recipe> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Recipe {
  final String recipeCode;
  final String name;
  final String mealType;
  final int? baseServings;
  final String instructions;
  final String? rawIngredients;

  Recipe({
    required this.recipeCode,
    required this.name,
    required this.mealType,
    this.baseServings,
    required this.instructions,
    this.rawIngredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        recipeCode: json["recipe_code"] ?? "",
        name: json["name"] ?? "Resep Tanpa Nama",
        mealType: json["meal_type"] ?? "",
        baseServings: json["base_servings"] != null
            ? int.tryParse(json["base_servings"].toString())
            : 1,
        instructions: json["instructions"] ?? "",
        rawIngredients: json["raw_ingredients"],
      );

  Map<String, dynamic> toJson() => {
        "recipe_code": recipeCode,
        "name": name,
        "meal_type": mealType,
        "base_servings": baseServings,
        "instructions": instructions,
        "raw_ingredients": rawIngredients,
      };
}
