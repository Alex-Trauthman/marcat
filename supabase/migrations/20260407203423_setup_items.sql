-- 1. Create 'items' table
CREATE TABLE IF NOT EXISTS public.items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) DEFAULT 0.00,
    image_url TEXT,
    contact_info TEXT
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;

-- 3. Create SELECT policy
CREATE POLICY "Public read access" 
ON public.items FOR SELECT 
USING (true);

-- 4. Initial mock data
INSERT INTO public.items (title, description, price, image_url, contact_info)
VALUES 
('Bicicleta Monark', 'Bicicleta em bom estado, linda e estilosa.', 250.00, 'assets/images/bicicleta.png', '11 99999-9999'),
('Secador de roupa', 'Secador portátil a energia solar (varal de chão). Totalmente renovável.', 115.00, 'assets/images/secador.jpg', '11 88888-8888'),
('Vitaminas', 'Uso recomendado para hipertrofia. Lacrado.', 300.00, 'assets/images/vitaminas.jpg', '11 77777-7777'),
('Doação de Livros', 'Diversos livros acadêmicos. Quem chegar primeiro leva.', 0.00, 'assets/images/livros.jpg', '11 66666-6666');

-- 5. Storage bucket setup (for product images)
-- First check if bucket exists, or just try insert
INSERT INTO storage.buckets (id, name, public) 
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- 6. Storage Policies
CREATE POLICY "Public image access"
ON storage.objects FOR SELECT
USING (bucket_id = 'product-images');

CREATE POLICY "Authenticated image upload"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'product-images' AND auth.role() = 'authenticated');
