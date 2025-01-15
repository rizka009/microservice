const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('rating-db', 'root', 'root', {
    host: process.env.DB_HOST, 
    dialect: 'mysql',          
    port: 3306                 
});

module.exports = sequelize;