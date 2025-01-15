const express = require("express");
const app = express();
const sequelize = require("./database");
const { DataTypes } = require("sequelize");
const cors = require("cors");
const axios = require("axios");

app.use(express.json());
app.use(cors());

// Model Rating
const Rating = sequelize.define("Rating", {
  recipe_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  rating: {
    type: DataTypes.FLOAT, // Ubah ke FLOAT untuk mendukung desimal
    allowNull: false,
    validate: {
      min: 1, // Rentang nilai minimum
      max: 10, // Rentang nilai maksimum
    },
  },
  comment: {
    type: DataTypes.STRING,
    allowNull: true,
  },
});

// Inisialisasi Database
const initDb = async () => {
  try {
    await sequelize.sync({ alter: true });
    console.log("Ratings table synced with database");
  } catch (error) {
    console.error("Error creating database tables:", error);
  }
};

initDb();

// Helper Functions
const successResponse = (res, message, data = null) => {
  res.status(200).json({
    success: true,
    message: message,
    data: data,
  });
};

const errorResponse = (res, status, message) => {
  res.status(status).json({
    success: false,
    message: message,
  });
};

const checkRecipeExists = async (recipe_id) => {
  try {
    const response = await axios.get(`http://recipe-service:3002/recipes`);
    if (response.data.success && Array.isArray(response.data.data)) {
      return response.data.data.find((r) => r.id === recipe_id) || null;
    }
    return null;
  } catch (error) {
    console.error("Error validating recipe:", error.message);
    return null;
  }
};

// Endpoint: Tambah Rating Baru
app.post("/ratings", async (req, res) => {
  try {
    const { recipe_id, rating, comment } = req.body;

    if (!recipe_id || rating == null) {
      return errorResponse(res, 400, "Recipe ID and Rating are required");
    }

    if (rating < 1 || rating > 10) {
      return errorResponse(res, 400, "Rating must be between 1 and 10");
    }

    const recipe = await checkRecipeExists(recipe_id);
    if (!recipe) {
      return errorResponse(res, 404, "Recipe not found in Recipe Service");
    }

    const newRating = await Rating.create({ recipe_id, rating, comment });
    successResponse(res, "New Rating Created", newRating);
  } catch (error) {
    console.error("Error creating rating:", error.message);
    errorResponse(res, 500, "Error Creating Rating");
  }
});

// Endpoint: Ambil Semua Rating (dengan atau tanpa recipe_id)
app.get("/ratings", async (req, res) => {
  try {
    const { recipe_id } = req.query;

    if (recipe_id) {
      const ratings = await Rating.findAll({ where: { recipe_id } });
      return successResponse(res, "Ratings Retrieved Successfully", ratings);
    }

    const ratings = await Rating.findAll();

    if (ratings.length === 0) {
      return successResponse(res, "No Ratings Found", []);
    }

    const response = await axios.get(`http://recipe-service:3002/recipes`);
    if (!response.data.success || !Array.isArray(response.data.data)) {
      return errorResponse(res, 500, "Error Fetching Recipes from Recipe Service");
    }

    const recipes = response.data.data;

    const enrichedRatings = ratings.map((rating) => {
      const recipe = recipes.find((r) => r.id === rating.recipe_id);
      return {
        ...rating.dataValues,
        recipe: recipe || null,
      };
    });

    successResponse(res, "All Ratings with Recipe Data Retrieved Successfully", enrichedRatings);
  } catch (error) {
    console.error("Error retrieving ratings:", error.message);
    errorResponse(res, 500, "Error Retrieving Ratings");
  }
});

// Start Server
app.listen(3000, () => {
  console.log("Rating Service is listening on port 3000");
});
