# Data Integration Overview

## Source Systems

### CRM (Customer Relationship Management)
**Purpose:** Transactional records about Sales & Orders

#### Tables

**crm_prd_info**
- **Purpose:** Current & History Product Information
- **Key Column:** `prd_key`
- **Entity Type:** PRODUCT (Red)

**crm_sales_details**
- **Purpose:** Transactional Records about Sales & Orders
- **Key Columns:** 
  - `prd_key` (links to crm_prd_info)
  - `cst_id` (links to crm_cust_info)
- **Entity Type:** SALES (Gray)

**crm_cust_info**
- **Purpose:** Customer Information
- **Key Columns:**
  - `cst_id`
  - `cst_key`
- **Entity Type:** CUSTOMER (Green)

---

### ERP (Enterprise Resource Planning)

#### Tables

**erp_px_cat_g1v2**
- **Purpose:** Product Categories
- **Key Column:** `id`
- **Entity Type:** PRODUCT (Red)

**erp_cust_az12**
- **Purpose:** Extra Customer Information (Birthdate)
- **Key Column:** `cid`
- **Entity Type:** CUSTOMER (Green)

**erp_loc_a101**
- **Purpose:** Location of Customers (Country)
- **Key Column:** `cid`
- **Entity Type:** CUSTOMER (Green)

---

## Data Relationships

### Product Domain
| Source Table | Key Column | Target Table | Key Column | Relationship Type |
|-------------|-----------|--------------|-----------|-------------------|
| crm_prd_info | prd_key | crm_sales_details | prd_key | One-to-Many |
| crm_prd_info | prd_key | erp_px_cat_g1v2 | id | One-to-One |

### Customer Domain
| Source Table | Key Column | Target Table | Key Column | Relationship Type |
|-------------|-----------|--------------|-----------|-------------------|
| crm_cust_info | cst_id | crm_sales_details | cst_id | One-to-Many |
| crm_cust_info | cst_key | erp_cust_az12 | cid | One-to-One |
| crm_cust_info | cst_key | erp_loc_a101 | cid | One-to-One |

---

## Integration Keys

### CRM to ERP Mapping

**Customer Integration:**
- **CRM Key:** `cst_key` (from crm_cust_info)
- **ERP Key:** `cid` (in both erp_cust_az12 and erp_loc_a101)
- **Purpose:** Links customer records across CRM and ERP systems

**Product Integration:**
- **CRM Key:** `prd_key` (from crm_prd_info)
- **ERP Key:** `id` (from erp_px_cat_g1v2)
- **Purpose:** Links product records to category information

**Sales Transactions:**
- **Primary Keys:** 
  - `prd_key` → Product dimension
  - `cst_id` → Customer dimension
- **Purpose:** Central fact table linking customers and products through sales

---

## Entity Types Legend

| Color | Entity Type | Description |
|-------|-------------|-------------|
| Red | PRODUCT | Product-related tables and information |
| Gray | SALES | Transactional sales data |
| Green | CUSTOMER | Customer-related tables and information |
| Yellow | REFERENCE | Reference/lookup tables |