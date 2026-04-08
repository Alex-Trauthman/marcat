-- 1. Add new columns to the items table for C2C marketplace
ALTER TABLE public.items 
ADD COLUMN IF NOT EXISTS condition TEXT DEFAULT 'Usado',
ADD COLUMN IF NOT EXISTS seller_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- 2. Update existing mock data to have a generic seller (Optional, but good for consistency)
-- If we want to assign them to a specific user later, we can, but for now they can remain null or be assigned to the first user if one exists.
-- We'll leave them as NULL since the schema allows it, but new items should have a seller.

-- 3. Update RLS Policies for the items table
-- We already have a "Public read access" policy for SELECT.
-- Now we add policies for INSERT, UPDATE, and DELETE.

CREATE POLICY "Authenticated users can insert items" 
ON public.items FOR INSERT 
WITH CHECK (auth.uid() = seller_id);

CREATE POLICY "Users can update their own items" 
ON public.items FOR UPDATE 
USING (auth.uid() = seller_id);

CREATE POLICY "Users can delete their own items" 
ON public.items FOR DELETE 
USING (auth.uid() = seller_id);
