import express from 'express';
import cors from "cors";
import dotenv from 'dotenv';

import companiesRoutes from './routes/companiesRoutes.js';

dotenv.config();

const PORT = process.env.PORT || 5001;

const app = express();

// Cho phép Express đọc JSON gửi từ client/Postman
app.use(express.json());

//  test qua frontend hoặc localhost khác cổng
app.use(cors());

// Sử dụng routes
app.use('/api/companies', companiesRoutes);


app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

