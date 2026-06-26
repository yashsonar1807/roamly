const Destination = require('../models/Destination');

const seedDestinations = async () => {
  try {
    const count = await Destination.countDocuments();
    if (count === 0) {
      console.log('[Seed] Destinations collection is empty. Seeding India-only travel spots...');
      
      const indianDestinations = [
        {
          name: 'Taj Mahal, Agra',
          description: 'One of the seven wonders of the world, a stunning ivory-white marble monument.',
          iconName: 'account_balance_rounded',
          state: 'Uttar Pradesh',
        },
        {
          name: 'Manali, Himachal Pradesh',
          description: 'A high-altitude Himalayan resort town known for trekking, rafting, and stunning valley views.',
          iconName: 'landscape_rounded',
          state: 'Himachal Pradesh',
        },
        {
          name: 'Goa Beaches, Goa',
          description: 'World-famous coastline renowned for its sandy beaches, seafood, and historical Portuguese architecture.',
          iconName: 'beach_access_rounded',
          state: 'Goa',
        },
        {
          name: 'Munnar, Kerala',
          description: 'Lush hill station famous for its rolling tea estates, misty atmosphere, and exotic flora.',
          iconName: 'forest_rounded',
          state: 'Kerala',
        },
        {
          name: 'Varanasi, Uttar Pradesh',
          description: 'One of the oldest continuously inhabited cities, spiritual hub on the banks of the sacred River Ganges.',
          iconName: 'temple_hindu_rounded',
          state: 'Uttar Pradesh',
        },
      ];

      await Destination.insertMany(indianDestinations);
      console.log('[Seed] Successfully seeded 5 Indian destinations into the database.');
    } else {
      console.log(`[Seed] Destinations already seeded (found ${count} locations).`);
    }
  } catch (error) {
    console.error(`[Seed] Error seeding destinations: ${error.message}`);
  }
};

module.exports = seedDestinations;
