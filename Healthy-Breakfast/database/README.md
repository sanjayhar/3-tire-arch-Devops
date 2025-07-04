# Database Scripts

Run the following to create and seed the PostgreSQL database:

```bash
psql -U your_user -d your_db -f schema.sql
psql -U your_user -d your_db -f seed.sql
