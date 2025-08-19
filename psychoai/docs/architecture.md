# Arquitetura do projeto PsychoAI

Este documento resume as decisões arquiteturais atuais e recomendações práticas para evolução, com base em pesquisas recentes (Flutter/Dart oficiais, Very Good Ventures, Clean Architecture) e no estado do repositório.

## Visão geral

- Plataforma: Flutter (Material 3, theming customizado)
- Estado: Provider
- Navegação: previsto go_router (migrar do Navigator imperativo)
- Backend/Serviços:
  - Firebase (Core/Auth/Firestore)
  - MongoDB (mongo_dart) para dados adicionais
  - IA via provedores compatíveis com OpenAI (NVIDIA NIM, Alibaba DashScope)

## Estrutura sugerida por feature + camadas

Cada feature deve ter pastas de camadas claras:

- domain: entidades, value objects, contratos de repositório, use cases
- data: models (DTO), datasources (remoto/local), impls de repositório
- presentation: widgets, pages, controllers/providers, routing local

Exemplo:

```text
lib/features/memories/
  domain/
    entities/
    repositories/
    usecases/
  data/
    models/
    datasources/
    repositories/
  presentation/
    pages/
    widgets/
    controllers/
```

## Navegação

- Criar `lib/core/router/app_router.dart` com go_router
- Declarar rotas por feature (sub-rotas), guards com base no estado de auth

## Injeção de dependências

- get_it (e opcional injectable) para registrar services, repos, usecases
- Providers/Controllers resolvem dependências via construtor (injeção explícita)

## Lints e qualidade

- Adotado very_good_analysis (opiniativo)
- Personalizações locais em `analysis_options.yaml` para adoção gradual
- Manter cobertura de testes por feature (happy path + 1 edge)

## Segredos e configuração

- Nunca versionar chaves (ex.: NVIDIA NIM)
- Usar `--dart-define` e ler com `const String.fromEnvironment('KEY')`
- Ter arquivos `.env.example`/README com variáveis exigidas

## Próximos passos (incrementais)

1) Router central com go_router + AuthGuard
2) Externalizar chaves (dart-define) e remover hardcodes
3) Criar esqueleto por feature (domain/data/presentation) para Memories e Auth
4) DI com get_it e migração dos serviços
5) Aumentar lints estritos (reabilitar regras comentadas) conforme dívida reduz

## Referências

- [Flutter Architecture](https://docs.flutter.dev/app-architecture)
- [Dart Package Layout](https://dart.dev/tools/pub/package-layout)
- [Very Good Analysis](https://pub.dev/packages/very_good_analysis)
- [Very Good CLI (templates)](https://verygood.ventures/blog/very-good-cli)
- [Clean Architecture (material de referência)](https://resocoder.com/category/clean-architecture/)
