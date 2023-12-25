import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/models/shop_app/categories_model.dart';
import 'package:shop_app/models/shop_app/favorites_model.dart';
import 'package:shop_app/models/shop_app/home_model.dart';
import 'package:shop_app/models/shop_app/login_model.dart';
import 'package:shop_app/shared/components/constants.dart';
import 'package:shop_app/shared/network/remote/dio_helper.dart';
import 'package:shop_app/shared/network/remote/end_points.dart';

import '../../../models/shop_app/change_favorite_model.dart';
import '../../../models/shop_app/change_favorite_model.dart';
import '../../../modules/shop_app/cateogries/categories_screen.dart';
import '../../../modules/shop_app/favorites/favorites_screen.dart';
import '../../../modules/shop_app/products/products_screen.dart';
import '../../../modules/shop_app/settings/settings_screen.dart';
import 'states.dart';

class ShopCubit extends Cubit<ShopStates> {
  ShopCubit() : super(ShopInitialState());
  static ShopCubit get(context) => BlocProvider.of(context);

  int CurrentIndex = 0;

  List<Widget> bottomScreen = [
    ProductsScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  void Changebottom(int index) {
    CurrentIndex = index;
    emit(ShopChangeButtonNav());
  }

  HomeModel? homeModel;
  Map<int, bool> favourite = {};

  void getHomeData() {
    emit(ShopLoadingHomeDataState());
    DioHelper.getData(
      url: HOME,
      token: token,
    ).then((value) {
      homeModel = HomeModel.fromJson(value.data);
      homeModel?.data!.products.forEach((element) {
        favourite.addAll({element.id!: element.inFavorites!});
      });
      print(favourite.toString());

      //  printFullText(homeModel.toString());
      //print(homeModel?.status);
      emit(ShopSuccessHomeDataState());
    }).catchError((error) {
      emit(ShopErrorHomeDataState(error.toString()));
      print(error.toString());
    });
  }

  CategoriesModel? categoriesModel;

  void getCategories() {
    DioHelper.getData(
      url: CATEGORIES,
    ).then((value) {
      categoriesModel = CategoriesModel.fromJson(value.data);
      emit(ShopSuccessCategoriesState());
    }).catchError((error) {
      emit(ShopErrorCategoriesState(error.toString()));
      print(error.toString());
    });
  }

  ChangeFavoriteModel? changeFavoriteModel;

  void changeFavourite(int productID) {
    favourite[productID] = !favourite[productID]!;
    emit(ShopChangeFavoriteState());
    DioHelper.postData(
            url: FAVORITES, data: {'product_id': productID}, token: token)
        .then((value) {
      changeFavoriteModel = ChangeFavoriteModel.fromJson(value.data);
      print(value.data);
      if (!changeFavoriteModel!.status!) {
        favourite[productID] = !favourite[productID]!;
      } else {
        getFavorites();
      }
      emit(ShopSuccessChangeFavoriteState(changeFavoriteModel!));
    }).catchError((error) {
      favourite[productID] = !favourite[productID]!;
      emit(ShopErrorChangeFavoriteState(error.toString()));
    });
  }

  FavoritesModel? favoritesModel;

  void getFavorites() {
    emit(ShopLoadingGetFavoritesState());
    DioHelper.getData(
      url: FAVORITES,
      token: token,
    ).then((value) {
      favoritesModel = FavoritesModel.fromJson(value.data);
      emit(ShopSuccessGetFavoritesState());
    }).catchError((error) {
      emit(ShopErrorGetFavoritesState(error.toString()));
      print(error.toString());
    });
  }

  ShopLoginModel? userModel;

  void getUserData() {
    emit(ShopLoadingUserDataState());
    DioHelper.getData(
      url: PROFILE,
      token: token,
    ).then((value) {
      userModel = ShopLoginModel.fromjson(value.data);
      print(userModel?.data!.name);
      emit(ShopSuccessUserDataState(userModel!));
    }).catchError((error) {
      emit(ShopErrorUserDataState(error.toString()));
      print(error.toString());
    });
  }

  void UpdateUserData({
    required String name,
    required String email,
    required String phone,
  }) {
    emit(ShopLoadingUpdateUserState());
    DioHelper.putData(url: UPDATEPROFILE, token: token, data: {
      'name': name,
      'email': email,
      'phone': phone,
    }).then((value) {
      userModel = ShopLoginModel.fromjson(value.data);
      print(userModel?.data!.name);
      emit(ShopSuccessUpdateUserState(userModel!));
    }).catchError((error) {
      emit(ShopErrorUpdateUserState(error.toString()));
      print(error.toString());
    });
  }
}
