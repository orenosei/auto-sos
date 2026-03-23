import { sql } from "../config/db.js";

//CRUD cho companies

export const getAllCompanies = async (req, res) => {
  try {
    const companies = await sql.query("SELECT * FROM companies");
    console.log("Fetched companies:", companies);
    res.status(200).json({sucess: true, data: companies});
  } catch (error) {
    console.error("Error fetching companies:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const getCompanyById = async (req, res) => {
  const { id } = req.params;
  try {
    const company = await sql.query("SELECT * FROM companies WHERE id = $1", [id]);
    if (company.length === 0) {
      return res.status(404).json({ error: "Company not found" });
    }
    console.log("Fetched company:", company[0]);
    res.status(200).json({sucess: true, data: company[0]});
  } catch (error) {
    console.error(`Error fetching company with id ${id}:`, error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const createCompany = async (req, res) => {
  const { name, address_text, location, phone, service_area, license_info, is_verified, rating_avg, total_reviews,  created_at, updated_at} = req.body;
  try {
    const newCompany = await sql.query(
      "INSERT INTO companies (name, address_text, location, phone, service_area, license_info, is_verified, rating_avg, total_reviews, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING *",
      [name, address_text, location, phone, service_area, license_info, is_verified, rating_avg, total_reviews, created_at, updated_at]
    );
    console.log("Created company:", newCompany[0]);
    res.status(201).json({sucess: true, data: newCompany[0]});
  } catch (error) {
    console.error("Error creating company:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const updateCompany = async (req, res) => {
  const { id } = req.params;
  const { name, address_text, location, phone, service_area, license_info, is_verified, rating_avg, total_reviews, updated_at } = req.body;
  try {
    const updatedCompany = await sql.query(
      "UPDATE companies SET name = $1, address_text = $2, location = $3, phone = $4, service_area = $5, license_info = $6, is_verified = $7, rating_avg = $8, total_reviews = $9, updated_at = $10 WHERE id = $11 RETURNING *",
      [name, address_text, location, phone, service_area, license_info, is_verified, rating_avg, total_reviews, updated_at, id]
    );
    if (updatedCompany.length === 0) {
      return res.status(404).json({ error: "Company not found" });
    }
    console.log("Updated company:", updatedCompany[0]);
    res.status(200).json({sucess: true, data: updatedCompany[0]});
  } catch (error) {
    console.error(`Error updating company with id ${id}:`, error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const deleteCompany = async (req, res) => {
  const { id } = req.params;
  try {
    const deletedCompany = await sql.query(
      "DELETE FROM companies WHERE id = $1 RETURNING *",
      [id]
    );
    if (deletedCompany.length === 0) {
      return res.status(404).json({ error: "Company not found" });
    }
    console.log("Deleted company:", deletedCompany[0]);
    res.status(200).json({sucess: true, data: deletedCompany[0]});
  } catch (error) {
    console.error(`Error deleting company with id ${id}:`, error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};