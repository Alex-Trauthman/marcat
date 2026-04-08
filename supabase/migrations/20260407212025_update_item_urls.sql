-- Update existing items to use remote storage URLs
UPDATE public.items 
SET image_url = 'https://xonghjzfmktcasplbjcu.supabase.co/storage/v1/object/public/product-images/bicicleta.png'
WHERE title = 'Bicicleta Monark';

UPDATE public.items 
SET image_url = 'https://xonghjzfmktcasplbjcu.supabase.co/storage/v1/object/public/product-images/secador.jpg'
WHERE title = 'Secador de roupa';

UPDATE public.items 
SET image_url = 'https://xonghjzfmktcasplbjcu.supabase.co/storage/v1/object/public/product-images/vitaminas.jpg'
WHERE title = 'Vitaminas';

UPDATE public.items 
SET image_url = 'https://xonghjzfmktcasplbjcu.supabase.co/storage/v1/object/public/product-images/livros.jpg'
WHERE title = 'Doação de Livros';
