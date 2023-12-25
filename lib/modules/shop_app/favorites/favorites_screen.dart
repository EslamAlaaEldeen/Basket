
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/layout/shop_app/cubit/cubit.dart';
import 'package:shop_app/layout/shop_app/cubit/states.dart';
import 'package:shop_app/shared/components/components.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopCubit, ShopStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return ListView.separated(
          itemBuilder: (context, index) => buildListProduct(
            ShopCubit.get(context).favoritesModel!.data!.data![index].product!,
            context,
          ),
          separatorBuilder: (context, index) => MyDivider(),
          itemCount: ShopCubit.get(context).favoritesModel!.data!.data!.length,
        );
      },
    );
  }
}
