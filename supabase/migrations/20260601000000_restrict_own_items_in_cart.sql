-- Migration to restrict users from adding their own items to the cart
DROP POLICY IF EXISTS "Users can insert own cart items" ON public.cart_items;

CREATE POLICY "Users can insert own cart items"
ON public.cart_items FOR INSERT
WITH CHECK (
  auth.uid() = user_id AND 
  NOT EXISTS (
    SELECT 1 FROM public.items 
    WHERE items.id = item_id AND items.seller_id = auth.uid()
  )
);
