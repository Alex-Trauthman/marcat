# Roadmap de Desenvolvimento: Próximos Passos (Mar Cat - Projeto A2)

Este documento detalha o planejamento estratégico para a finalização do projeto **Mar Cat**, garantindo o cumprimento de todos os requisitos da A2 e a evolução da experiência do usuário.

---

## 1. Implementação de Requisitos Obrigatórios (A2)

Para satisfazer as exigências de **Uso de API REST** e **Recursos do Dispositivo**, seguiremos com:

### 1.1. Integração com API ViaCEP (REST)
*   **Funcionalidade:** No formulário de anúncio, ao digitar o CEP, o aplicativo consultará o webservice `https://viacep.com.br/` para preencher automaticamente os campos de endereço (Rua, Bairro, Cidade).
*   **Objetivo:** Agilizar o processo de cadastro e garantir a precisão da localização do item.

### 1.2. Recursos do Dispositivo: Câmera e Galeria
*   **Funcionalidade:** Permitir que o usuário escolha entre capturar uma foto em tempo real com a **Câmera** ou selecionar uma imagem existente na **Galeria**.
*   **Objetivo:** Cumprir o requisito de uso de hardware nativo do dispositivo.

---

## 2. Evolução da Área de Gestão (Menu & Perfil)

Focaremos em transformar o aplicativo de uma "vitrine de leitura" para uma "plataforma de gestão":

### 2.1. Gestão de Publicações (Meus Anúncios)
*   **Listagem Própria:** Nova tela dentro da seção "Menu" que exibe apenas os itens publicados pelo usuário logado.
*   **Edição (Edit):** Possibilidade de alterar título, preço, descrição ou imagem de um anúncio já existente.
*   **Remoção (Delete):** Implementação da exclusão lógica ou física do item no Supabase.

### 2.2. Gestão de Identidade (Perfil)
*   **Troca de Foto de Perfil:** Implementação completa do upload de imagem para o bucket `avatars` no Supabase, refletindo instantaneamente em todo o app (via `AuthController`).
*   **Remoção de Conta:** Opção de segurança para o usuário encerrar sua conta e remover seus dados do sistema.

### 2.3. Seção Suporte (Placeholder)
*   **Estado:** Implementação de uma tela de "Em Construção" para a área de suporte no Menu, mantendo a integridade visual da interface enquanto o recurso é desenvolvido futuramente.

---

**Status Atual:** Arquitetura MVCS estabilizada. Persistência Supabase ativa.
**Próxima Sprint:** Início da integração ViaCEP e ativação da Câmera.
