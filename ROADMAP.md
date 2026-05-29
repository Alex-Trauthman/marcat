# Roadmap de Desenvolvimento: Próximos Passos (Mar Cat - Projeto A2)

Este documento detalha o planejamento estratégico para o projeto **Mar Cat** (Projeto A2), acompanhando o status dos requisitos obrigatórios, melhorias de experiência de usuário e próximos passos para evolução do sistema.

---

## 1. Implementação de Requisitos Obrigatórios (A2) — [✓] 100% Concluído

### 1.1. Integração com API ViaCEP (REST) — [✓] Concluído
*   **Status:** Concluído e integrado.
*   **Funcionalidade:** No formulário de anúncio (`CreateItemScreen` e `EditItemScreen`), ao digitar o CEP (8 dígitos), o aplicativo consulta automaticamente o webservice `https://viacep.com.br/` para autopreencher os campos de endereço (Rua, Bairro, Cidade, Estado).
*   **Camada MVCS:** A chamada REST é isolada no `ItemService.fetchAddressFromCep()` e gerenciada pelo `ItemController.fetchAddressFromCep()`.

### 1.2. Recursos do Dispositivo: Câmera e Galeria — [✓] Concluído
*   **Status:** Concluído e integrado.
*   **Funcionalidade:** O usuário pode escolher entre capturar uma foto com a **Câmera** ou selecionar uma da **Galeria** usando o widget reutilizável `ImageSourceSheet` (Bottom Sheet).
*   **Locais de Uso:** Criação de anúncio, edição de anúncio e atualização da foto de perfil.

---

## 2. Evolução da Área de Gestão (Menu & Perfil) — [✓] 100% Concluído

### 2.1. Gestão de Publicações (Meus Anúncios) — [✓] Concluído
*   **Status:** Concluído e integrado.
*   **Listagem Própria:** Tela `MyItemsScreen` acessível pelo menu lateral, exibindo apenas as publicações do usuário ativo.
*   **Edição (Edit):** Tela `EditItemScreen` permitindo atualizar título, descrição, CEP, preço e imagem.
*   **Remoção (Delete):** Implementado no `ItemService.deleteItem()` e `ItemController.deleteItem()`, removendo fisicamente o registro do Supabase e sincronizando em tempo real com o feed principal.

### 2.2. Gestão de Identidade (Perfil) — [✓] Concluído
*   **Status:** Concluído e integrado.
*   **Troca de Foto de Perfil:** Tela `EditProfileScreen` com suporte a upload da nova imagem para o bucket `avatars` no Supabase Storage. O `AuthController` atualiza o estado global e reflete a nova foto instantaneamente por toda a aplicação.
*   **Remoção de Conta:** Função de segurança para exclusão permanente do usuário e seus anúncios via RPC `delete_own_user` no banco de dados.

### 2.3. Seção Suporte (Placeholder) — [✓] Concluído
*   **Status:** Concluído.
*   **Estado:** Tela de placeholder dedicada (`SupportPlaceholderScreen`) com feedback visual polido sobre o estado de desenvolvimento futuro.

---

## 3. Próximos Passos (Evolução Pós-A2)

Com todos os requisitos da A2 satisfeitos e integrados com sucesso na arquitetura MVCS, o planejamento futuro foca em:

1.  **Testes de Unidade e Integração Adicionais:**
    *   Criação de mocks para o `ItemService` e `AuthService` utilizando Mockito para testar fluxos de erro e regras de negócio.
2.  **Notificações em Tempo Real:**
    *   Configuração do Supabase Realtime para notificar usuários de novos anúncios ou alterações instantâneas sem necessidade de puxar para atualizar (*pull-to-refresh*).
3.  **Melhorias na UX e Design System:**
    *   Implementação de animações de transição de tela personalizadas.
    *   Suporte para Tema Escuro (Dark Mode).

---

**Status Atual:** Todos os requisitos da A2 implementados, testados (`flutter test` passou com sucesso) e validados na arquitetura MVCS.
**Próxima Sprint:** Otimizações de layout e cobertura de testes.
