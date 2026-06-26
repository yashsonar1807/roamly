const Destination = require('../models/Destination');
const Story = require('../models/Story');
const Post = require('../models/Post');

const seedDatabase = async () => {
  try {
    // 1. Seed Destinations
    const destCount = await Destination.countDocuments();
    if (destCount < 15) {
      console.log('[Seed] Destinations count is less than 15. Re-seeding complete list...');
      await Destination.deleteMany({}); // Clear existing
      
      const indianDestinations = [
        {
          name: 'Taj Mahal',
          city: 'Agra',
          country: 'India',
          description: 'One of the seven wonders of the world, a stunning ivory-white marble monument built on the banks of the Yamuna River.',
          images: ['https://images.unsplash.com/photo-1564507592333-c60657eea523?q=80&w=600'],
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
          images: ['https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=600'],
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
          images: ['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600'],
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
          images: ['https://images.unsplash.com/photo-1593693397690-362cb9666fc2?q=80&w=600'],
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
          images: ['https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?q=80&w=600'],
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
          images: ['https://images.unsplash.com/photo-1477584305850-3a7ac0197a19?q=80&w=600'],
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
          images: ['https://images.unsplash.com/photo-1615959189197-484c0fc456a1?q=80&w=600'],
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
          description: 'A large open space located in the center of Shimla, offering panoramic views of the snowy Himalayan peaks.',
          images: ['https://images.unsplash.com/photo-1597075687490-8f673c6c17f6?q=80&w=600'],
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
          description: 'Consistently rated as one of Asia\'s best beaches, featuring turquoise water and pristine white sand shores.',
          images: ['https://images.unsplash.com/photo-1589308078059-be1415eab4c3?q=80&w=600'],
          latitude: 12.0305,
          longitude: 92.9576,
          rating: 4.9,
          category: 'Beaches',
          iconName: 'beach_access_rounded',
        },
        {
          name: 'Rishikesh Rafting',
          city: 'Rishikesh',
          country: 'India',
          description: 'Experience white-water rafting on the Ganga River, surrounded by the beautiful foothills of the Himalayas.',
          images: ['https://images.unsplash.com/photo-1530521951415-3dbd6855567a?q=80&w=600'],
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
          images: ['https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=600'],
          latitude: 34.1526,
          longitude: 77.5771,
          rating: 4.9,
          category: 'Adventure',
          iconName: 'explore_rounded',
        },
        {
          name: 'Alleppey Houseboats',
          city: 'Alleppey',
          country: 'India',
          description: 'Glide along tranquil backwaters, palm-fringed canals, and lagoons in traditional Kerala houseboats.',
          images: ['https://images.unsplash.com/photo-1593693411515-c202e974fe08?q=80&w=600'],
          latitude: 9.4981,
          longitude: 76.3388,
          rating: 4.7,
          category: 'Beaches',
          iconName: 'beach_access_rounded',
        },
        {
          name: 'Gulmarg Gondola',
          city: 'Gulmarg',
          country: 'India',
          description: 'One of the highest cable cars in the world, taking you to snow-capped peak viewpoints for skiing and photography.',
          images: ['https://images.unsplash.com/photo-1588668214407-6eb9527032d6?q=80&w=600'],
          latitude: 34.0484,
          longitude: 74.3805,
          rating: 4.8,
          category: 'Mountains',
          iconName: 'landscape_rounded',
        },
        {
          name: 'Ajanta Caves',
          city: 'Aurangabad',
          country: 'India',
          description: 'Ancient rock-cut Buddhist caves featuring beautiful frescoes, sculptures, and architectural wonders.',
          images: ['https://images.unsplash.com/photo-1600100397608-f010e42ed7b4?q=80&w=600'],
          latitude: 20.5519,
          longitude: 75.7031,
          rating: 4.6,
          category: 'Heritage',
          iconName: 'account_balance_rounded',
        },
        {
          name: 'Ooty Botanical Gardens',
          city: 'Ooty',
          country: 'India',
          description: 'Lush gardens showcasing thousands of species of flora, neat lawns, and ancient fossil tree trunks.',
          images: ['https://images.unsplash.com/photo-1588096344356-9b9d31bf9a89?q=80&w=600'],
          latitude: 11.4102,
          longitude: 76.7084,
          rating: 4.5,
          category: 'Forests',
          iconName: 'forest_rounded',
        },
      ];
      await Destination.insertMany(indianDestinations);
      console.log('[Seed] 15 destinations seeded successfully.');
    }

    // 2. Seed Stories
    const storyCount = await Story.countDocuments();
    if (storyCount === 0) {
      console.log('[Seed] Seeding user stories...');
      const stories = [
        {
          userName: 'Aarav',
          userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200',
        },
        {
          userName: 'Ananya',
          userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200',
        },
        {
          userName: 'Kabir',
          userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200',
        },
        {
          userName: 'Diya',
          userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
        },
        {
          userName: 'Rohan',
          userAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?q=80&w=200',
        },
      ];
      await Story.insertMany(stories);
      console.log('[Seed] Stories seeded successfully.');
    }

    // 3. Seed Posts
    const postCount = await Post.countDocuments();
    if (postCount === 0) {
      console.log('[Seed] Seeding feed posts...');
      const posts = [
        {
          authorName: 'Amit Sharma',
          authorRole: 'Explorer',
          authorAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200',
          title: 'Watching sunrise in Varanasi 🌅',
          description: 'Witnessed the spiritual Ganga Aarti at sunrise. There is an inexplicable tranquility in the air of Varanasi that everyone must experience at least once.',
          image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?q=80&w=600',
          likesCount: 1200,
          commentsCount: 45,
        },
        {
          authorName: 'Priya Patel',
          authorRole: 'Vagabond',
          authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
          title: 'Chasing waves in South Goa 🌊',
          description: 'Spent the day exploring isolated beaches in Palolem. White sands, clear water, and fresh coconut water. Truly paradise!',
          image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600',
          likesCount: 890,
          commentsCount: 23,
        },
      ];
      await Post.insertMany(posts);
      console.log('[Seed] Feed posts seeded successfully.');
    }
  } catch (error) {
    console.error(`[Seed] Error seeding database: ${error.message}`);
  }
};

module.exports = seedDatabase;
