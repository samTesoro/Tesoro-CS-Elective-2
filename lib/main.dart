import 'package:flutter/material.dart';

void main() {
  runApp(const NetflixClone());
}

class NetflixClone extends StatelessWidget {
  const NetflixClone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget movieCard(String image) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 140,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          /// Background
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              "assets/atlas.jpg",
              fit: BoxFit.cover,
            ),
          ),

          /// Dark Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black54,
                  Colors.black,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  /// Header
                  Row(
                    children: [

                      const Text(
                        "For Debbie",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.cast,
                          color: Colors.white,
                        ),
                      ),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// Chips
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      chip("TV Shows"),

                      chip("Movies"),

                      chip("Categories"),
                    ],
                  ),

                  const Spacer(),

                  /// Movie Title
                  const Text(
                    "Atlas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Science fiction • Action",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Buttons
                  Row(
                    children: [

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white54,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.play_arrow,
                          ),
                          label: const Text("Play"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: const [

                      Text(
                        "My List",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Spacer(),

                      Text(
                        "See all",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      SizedBox(width: 5),

                      Icon(
                        Icons.chevron_right,
                        color: Colors.white70,
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [

                        movieCard("assets/movie1.jpg"),

                        movieCard("assets/movie2.jpg"),

                        movieCard("assets/movie1.jpg"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff24232A),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: "",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "",
          ),
        ],
      ),
    );
  }
}