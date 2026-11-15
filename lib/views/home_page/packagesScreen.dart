import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umrahapp/utils/helper_function.dart';
import 'package:umrahapp/views/home_page/data/category_model.dart';
import 'package:umrahapp/views/home_page/package_detail_screen.dart';
import 'package:umrahapp/views/home_page/widgets/packages2_card.dart';

import 'home_bloc/home_bloc.dart';

class Packagesscreen extends StatefulWidget {
  const Packagesscreen({super.key});

  @override
  State<Packagesscreen> createState() => _PackagesscreenState();
}

class _PackagesscreenState extends State<Packagesscreen> {
  List<CategoryModel> allPackages = [];
  List<CategoryModel> filterPackages = [];
  String selectedCategory = 'الكل';
  final List<String> categories = ['الكل', 'اقتصادية', 'متوسطة', 'مميزة'];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 138,
          centerTitle: true,
          title: Text(
            'الباقات',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 25,
            ),
          ),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is LoadingCategoryState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SuccessCategoryState) {
              final allPackages = state.data;
              final displayedPackages = selectedCategory == 'الكل'
                  ? allPackages
                  : allPackages.where((package) {
                      return package.name!.contains(selectedCategory);
                    }).toList();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 24),
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          return ChoiceChip(
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(width: 0.2),

                            backgroundColor: Color.fromRGBO(239, 250, 243, 0.4),

                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: selectedCategory == category
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<HomeBloc>().add(GetHomeCategories());
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: displayedPackages.length,
                          itemBuilder: (context, index) {
                            final package = displayedPackages[index];

                            return InkWell(
                              onTap: () {
                                HelperFunction.navigate(
                                  context,
                                  PackageDetailScreen(package: package),
                                );
                              },
                              child: PackageCard(package: package),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is FailedCategoryState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 70,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'تعذر تحميل الباقات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'يبدو أن هناك مشكلة في الاتصال بالإنترنت.\n'
                        'تأكد من اتصالك بالإنترنت ثم حاول مرة أخرى.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 25),

                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<HomeBloc>().add(GetHomeCategories());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
