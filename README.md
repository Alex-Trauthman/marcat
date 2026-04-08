# Mar Cat

Um marketplace moderno Consumer-to-Consumer (C2C) para venda e doação de itens usados, inspirado na simplicidade e eficiência da OLX. Desenvolvido com Flutter e integrado ao Supabase para uma experiência robusta e escalável.

## Funcionalidades

- Marketplace C2C: Poste anúncios de venda ou doação de forma rápida.
- Autenticação Segura: Fluxo completo de Login e Cadastro via Supabase Auth.
- Gerenciamento de Itens: Upload de imagens reais para o banco de dados e controle de estado do item (Novo, Usado, etc.).
- Interface Moderna: Design limpo em tons de amarelo pastel e creme, utilizando Material 3.
- Navegação Intuitiva: Barra de navegação inferior com acesso rápido a Home, Favoritos, Anúncios e Perfil.
- Experiência Brasileira: Formatação de preços e campos de contato adaptados para o mercado nacional.

## Tecnologias

- Flutter: Framework principal para UI multi-plataforma.
- Supabase: Backend-as-a-Service (BaaS) gerenciando:
  - Banco de Dados PostgreSQL.
  - Autenticação de Usuários.
  - Storage para imagens de produtos.
- Flutter Dotenv: Gerenciamento seguro de variáveis de ambiente.
- Image Picker: Integração com a galeria do dispositivo para anúncios.

## Como Executar

1. Configuração do Ambiente:
   - Certifique-se de ter o Flutter instalado (flutter doctor).
   - Crie um arquivo .env na raiz do projeto seguindo o padrão:
     ```env
     SUPABASE_URL=sua_url_aqui
     SUPABASE_ANON_KEY=sua_chave_aqui
     ```

2. Dependências:
   ```bash
   flutter pub get
   ```

3. Rodar o App:
   ```bash
   flutter run
   ```

## Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.
