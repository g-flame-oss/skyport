//*custom seed by G-flame
console.log('Custom seed by G-flame!');
console.log('check out my other projects at https://github.com/g-flame-oss');

// start of seeding
const axios = require('axios');
const { db } = require('../handlers/db');
const log = new (require('cat-loggr'))();
const readline = require('readline');
const { v4: uuidv4 } = require('uuid');
const config = require('../config.json');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

async function seed() {
  try {
    const existingImages = await db.get('images');
    if (existingImages && existingImages.length > 0) {
      rl.question(
        "'images' is already set in the database. Do you want to continue seeding? (y/n) ",
        async (answer) => {
          if (answer.toLowerCase() !== 'y') {
            log.info('Seeding aborted by the user.');
            rl.close();
            process.exit(0);
          } else {
            await performSeeding();
            rl.close();
          }
        }
      );
    } else {
      await performSeeding();
      rl.close();
    }
  } catch (error) {
    log.error(`Failed during seeding process: ${error}`);
    rl.close();
  }
}

async function performSeeding() {
  try {
    const response = await axios.get(
      'https://raw.githubusercontent.com/g-flame-oss/Docker-Projects/refs/heads/main/assets/skyport/fabric/Fabric-1.21.json'
    );
    const imageData = response.data;

    log.info('Received image configuration data');

    // Add UUID to the image data
    imageData.Id = uuidv4();

    // Create or update the images array in the database
    let existingImages = (await db.get('images')) || [];

    // Check if this image already exists (by Name or another unique identifier)
    const existingIndex = existingImages.findIndex(
      (img) => img.Name === imageData.Name
    );

    if (existingIndex !== -1) {
      // Update existing image
      existingImages[existingIndex] = imageData;
      log.info(`Updated existing image: ${imageData.Name}`);
    } else {
      // Add new image
      existingImages.push(imageData);
      log.info(`Added new image: ${imageData.Name}`);
    }

    // Save to database
    await db.set('images', existingImages);
    log.info('Seeding complete!');
  } catch (error) {
    log.error(`Failed to fetch or store image data: ${error}`);
    if (error.response) {
      log.error('Response status:', error.response.status);
      log.error('Response data:', error.response.data);
    }
  }
}

seed();

process.on('exit', (code) => {
  log.info(`Exiting with code ${code}`);
});

process.on('unhandledRejection', (reason, promise) => {
  log.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});
