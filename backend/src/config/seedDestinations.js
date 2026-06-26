const Destination = require('../models/Destination');

const seedDestinations = async () => {
  try {
    const count = await Destination.countDocuments();
    if (count === 0) {
      console.log('[Seed] Destinations collection is empty. Seeding India-only travel spots with full coordinates and details...');
      
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
      ];

      await Destination.insertMany(indianDestinations);
      console.log('[Seed] Successfully seeded 5 detailed Indian destinations.');
    } else {
      console.log(`[Seed] Destinations already seeded (found ${count} locations).`);
    }
  } catch (error) {
    console.error(`[Seed] Error seeding destinations: ${error.message}`);
  }
};

module.exports = seedDestinations;
