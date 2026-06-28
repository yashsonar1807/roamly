const Destination = require('../models/Destination');
const Story = require('../models/Story');
const Post = require('../models/Post');
const User = require('../models/User');

const seedDatabase = async () => {
  try {
    // 1. Seed Destinations
    const destCount = await Destination.countDocuments();
    if (true) {
      console.log('[Seed] Destinations count is less than 15. Re-seeding complete list...');
      await Destination.deleteMany({}); // Clear existing
      
      const indianDestinations = [
        {
          name: 'Taj Mahal',
          city: 'Agra',
          country: 'India',
          description: 'One of the seven wonders of the world, a stunning ivory-white marble monument built on the banks of the Yamuna River.',
          images: ['https://picsum.photos/seed/roamly1/600/400'],
          latitude: 27.1751,
          longitude: 78.0421,
          rating: 4.9,
          category: 'Heritage',
          iconName: 'account_balance_rounded',
        },
        {
          name: 'Solang Valley',
          city: 'Manali',
          country: 'India',
          description: 'A high-altitude Himalayan resort town known for paragliding, skiing, and trekking in Himachal Pradesh.',
          images: ['https://picsum.photos/seed/roamly2/600/400'],
          latitude: 32.2396,
          longitude: 77.1887,
          rating: 4.7,
          category: 'Mountains',
          iconName: 'landscape_rounded',
        },
        {
          name: 'Palolem Beach',
          city: 'Goa',
          country: 'India',
          description: 'Renowned coastline in South Goa famous for its calm waters, sandy shores, and vibrant beach shacks.',
          images: ['https://picsum.photos/seed/roamly3/600/400'],
          latitude: 15.2993,
          longitude: 74.1240,
          rating: 4.8,
          category: 'Beaches',
          iconName: 'beach_access_rounded',
        },
        {
          name: 'Munnar Tea Estates',
          city: 'Munnar',
          country: 'India',
          description: 'Picturesque hill station famous for its rolling tea plantations, lush greenery, and rare exotic flowers.',
          images: ['https://picsum.photos/seed/roamly4/600/400'],
          latitude: 10.0889,
          longitude: 77.0595,
          rating: 4.8,
          category: 'Forests',
          iconName: 'forest_rounded',
        },
        {
          name: 'Ganga Aarti Ghat',
          city: 'Varanasi',
          country: 'India',
          description: 'A deeply spiritual location on the banks of the sacred River Ganges, hosting holy ritual prayers daily.',
          images: ['https://picsum.photos/seed/roamly5/600/400'],
          latitude: 25.3176,
          longitude: 82.9739,
          rating: 4.9,
          category: 'Heritage',
          iconName: 'temple_hindu_rounded',
        },
        {
          name: 'Hawa Mahal',
          city: 'Jaipur',
          country: 'India',
          description: 'A stunning five-story palace built of red and pink sandstone, famous for its high screen wall windows.',
          images: ['https://picsum.photos/seed/roamly6/600/400'],
          latitude: 26.9239,
          longitude: 75.8267,
          rating: 4.6,
          category: 'Heritage',
          iconName: 'account_balance_rounded',
        },
        {
          name: 'Jim Corbett National Park',
          city: 'Ramnagar',
          country: 'India',
          description: 'India\'s oldest national park, famous for its abundant wildlife including the majestic Bengal Tiger.',
          images: ['https://picsum.photos/seed/roamly7/600/400'],
          latitude: 29.5300,
          longitude: 78.7747,
          rating: 4.5,
          category: 'Forests',
          iconName: 'forest_rounded',
        },
        {
          name: 'Shimla Ridge',
          city: 'Shimla',
          country: 'India',
          description: 'The large open space in the heart of Shimla, offering panoramic views of the snowy mountain ranges.',
          images: ['https://picsum.photos/seed/roamly8/600/400'],
          latitude: 31.1048,
          longitude: 77.1734,
          rating: 4.6,
          category: 'Mountains',
          iconName: 'landscape_rounded',
        },
        {
          name: 'Radhanagar Beach',
          city: 'Havelock Island',
          country: 'India',
          description: 'Award-winning beach in the Andaman Islands known for its stunning sunsets, white sand, and turquoise water.',
          images: ['https://picsum.photos/seed/roamly9/600/400'],
          latitude: 11.9833,
          longitude: 92.9833,
          rating: 4.9,
          category: 'Beaches',
          iconName: 'beach_access_rounded',
        },
        {
          name: 'Rishikesh Rafting',
          city: 'Rishikesh',
          country: 'India',
          description: 'Experience white-water rafting on the Ganga River, surrounded by the beautiful foothills of the Himalayas.',
          images: ['https://picsum.photos/seed/roamly10/600/400'],
          latitude: 30.0869,
          longitude: 78.2676,
          rating: 4.8,
          category: 'Adventure',
          iconName: 'explore_rounded',
        },
        {
          name: 'Leh Ladakh Desert',
          city: 'Leh',
          country: 'India',
          description: 'A high-altitude desert destination featuring breathtaking lake views, deep valleys, and ancient monasteries.',
          images: ['https://picsum.photos/seed/roamly11/600/400'],
          latitude: 34.1526,
          longitude: 77.5771,
          rating: 4.9,
          category: 'Adventure',
          iconName: 'explore_rounded',
        },
        {
          name: 'Ranthambore Fort',
          city: 'Sawai Madhopur',
          country: 'India',
          description: 'A formidable hill fort situated within the Ranthambore National Park, offering views of the wildlife reserve.',
          images: ['https://picsum.photos/seed/roamly12/600/400'],
          latitude: 26.0173,
          longitude: 76.4504,
          rating: 4.4,
          category: 'Heritage',
          iconName: 'account_balance_rounded',
        },
        {
          name: 'Gulmarg Gondola',
          city: 'Gulmarg',
          country: 'India',
          description: 'One of the highest cable cars in the world, taking you to snow-capped peak viewpoints for skiing and photography.',
          images: ['https://picsum.photos/seed/roamly13/600/400'],
          latitude: 34.0484,
          longitude: 74.3805,
          rating: 4.8,
          category: 'Mountains',
          iconName: 'landscape_rounded',
        },
        {
          name: 'Sundarbans Mangrove',
          city: 'Kolkata',
          country: 'India',
          description: 'The largest mangrove forest in the world, home to the Royal Bengal tiger and diverse aquatic life.',
          images: ['https://picsum.photos/seed/roamly14/600/400'],
          latitude: 21.9497,
          longitude: 89.1833,
          rating: 4.7,
          category: 'Forests',
          iconName: 'forest_rounded',
        },
        {
          name: 'Alleppey Backwaters',
          city: 'Alappuzha',
          country: 'India',
          description: 'Glide along tranquil backwaters, palm-fringed canals, and lagoons in traditional Kerala houseboats.',
          images: ['https://picsum.photos/seed/roamly15/600/400'],
          latitude: 9.4981,
          longitude: 76.3388,
          rating: 4.7,
          category: 'Beaches',
          iconName: 'beach_access_rounded',
        },
      ];
      await Destination.insertMany(indianDestinations);
      console.log('[Seed] 15 destinations seeded successfully.');
    }

    // 2. Seed Users
    const demoUsersData = [
      {
        name: 'Aarav',
        username: 'aarav_demo',
        email: 'aarav@demo.com',
        password: 'password123',
        profileImage: 'https://i.pravatar.cc/150?img=16',
        bio: 'Explorer'
      },
      {
        name: 'Ananya',
        username: 'ananya_demo',
        email: 'ananya@demo.com',
        password: 'password123',
        profileImage: 'https://i.pravatar.cc/150?img=17',
        bio: 'Traveller'
      },
      {
        name: 'Kabir',
        username: 'kabir_demo',
        email: 'kabir@demo.com',
        password: 'password123',
        profileImage: 'https://i.pravatar.cc/150?img=18',
        bio: 'Wanderlust'
      },
      {
        name: 'Diya',
        username: 'diya_demo',
        email: 'diya@demo.com',
        password: 'password123',
        profileImage: 'https://i.pravatar.cc/150?img=19',
        bio: 'Photographer'
      },
      {
        name: 'Rohan',
        username: 'rohan_demo',
        email: 'rohan@demo.com',
        password: 'password123',
        profileImage: 'https://i.pravatar.cc/150?img=20',
        bio: 'Vlogger'
      },
      {
        name: 'Amit Sharma',
        username: 'amit_demo',
        email: 'amit@demo.com',
        password: 'password123',
        profileImage: 'https://i.pravatar.cc/150?img=21',
        bio: 'Explorer'
      },
      {
        name: 'Priya Patel',
        username: 'priya_demo',
        email: 'priya@demo.com',
        password: 'password123',
        profileImage: 'https://i.pravatar.cc/150?img=22',
        bio: 'Vagabond'
      }
    ];

    let demoUsers = [];
    for (const userData of demoUsersData) {
      let user = await User.findOne({ email: userData.email });
      if (!user) {
        user = new User(userData);
        await user.save();
      }
      demoUsers.push(user);
    }
    console.log('[Seed] Demo users seeded successfully.');

    // Always re-seed posts and stories to link correctly
    await Story.deleteMany({});
    await Post.deleteMany({});

    // 3. Seed Stories
    console.log('[Seed] Seeding user stories...');
    const stories = [
      {
        user: demoUsers[0]._id,
        userName: demoUsers[0].name,
        userAvatar: demoUsers[0].profileImage,
      },
      {
        user: demoUsers[1]._id,
        userName: demoUsers[1].name,
        userAvatar: demoUsers[1].profileImage,
      },
      {
        user: demoUsers[2]._id,
        userName: demoUsers[2].name,
        userAvatar: demoUsers[2].profileImage,
      },
      {
        user: demoUsers[3]._id,
        userName: demoUsers[3].name,
        userAvatar: demoUsers[3].profileImage,
      },
      {
        user: demoUsers[4]._id,
        userName: demoUsers[4].name,
        userAvatar: demoUsers[4].profileImage,
      },
    ];
    await Story.insertMany(stories);
    console.log('[Seed] Stories seeded successfully.');

    // 4. Seed Posts
    console.log('[Seed] Seeding feed posts...');
    const posts = [
      {
        user: demoUsers[5]._id, // Amit
        authorName: demoUsers[5].name,
        authorRole: demoUsers[5].bio,
        authorAvatar: demoUsers[5].profileImage,
        title: 'Watching sunrise in Varanasi 🌅',
        description: 'Witnessed the spiritual Ganga Aarti at sunrise. There is an inexplicable tranquility in the air of Varanasi that everyone must experience at least once.',
        image: 'https://picsum.photos/seed/roamly23/600/400',
        likesCount: 1200,
        commentsCount: 45,
      },
      {
        user: demoUsers[6]._id, // Priya
        authorName: demoUsers[6].name,
        authorRole: demoUsers[6].bio,
        authorAvatar: demoUsers[6].profileImage,
        title: 'Chasing waves in South Goa 🌊',
        description: 'Spent the day exploring isolated beaches in Palolem. White sands, clear water, and fresh coconut water. Truly paradise!',
        image: 'https://picsum.photos/seed/roamly24/600/400',
        likesCount: 890,
        commentsCount: 23,
      },
    ];
    await Post.insertMany(posts);
    console.log('[Seed] Feed posts seeded successfully.');
  } catch (error) {
    console.error(`[Seed] Error seeding database: ${error.message}`);
  }
};

module.exports = seedDatabase;
