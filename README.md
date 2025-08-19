# PsychoAI: Sistema de Pré-Análise Psicanalítica com IA

## 🧠 Sobre o Projeto

Aplicação Flutter (mobile/web) que utiliza Inteligência Artificial para analisar lembranças de pacientes, identificando
padrões psicanalíticos baseados na teoria freudiana das "lembranças encobridoras".

## 🎯 Problema Identificado

- **Tempo limitado** nas sessões de psicanálise (50 minutos padrão)
- **Dificuldade em detectar** "lembranças encobridoras" em tempo real
- **Falta de análise prévia** das narrativas dos pacientes
- **Padrões repetitivos** que passam despercebidos entre sessões

## 💡 Solução Proposta

### Para Pacientes

- Interface intuitiva para registro de lembranças (livre associação digital)
- Ambiente seguro e calmante para expressão
- Histórico pessoal de memórias e insights

### Para Psicanalistas

- Relatórios de pré-análise gerados por IA
- Dashboard com insights sobre padrões comportamentais
- Timeline visual do progresso do paciente
- Sugestões de tópicos para explorar na sessão

## 🛠 Tecnologias

- **Frontend**: Flutter 3.32.6 (iOS, Android, Web)
- **IA**: NVIDIA AI APIs (Llama 3.1, Mistral)
- **Deploy**: GitHub Pages
- **Design**: Material Design 3 com paleta terapêutica
- **Segurança**: Criptografia end-to-end, compliance LGPD

## 📊 Resultados Esperados

- **30% de redução** no tempo de identificação de padrões
- **NPS > 8.0** na avaliação de usabilidade
- **85% de concordância** entre análise IA e avaliação profissional
- **Interface acessível** para diferentes perfis de usuários

## 🎨 Design Principles

### Paleta de Cores Terapêutica

- **Primary**: #6B5B95 (Lavanda profunda - tranquilidade)
- **Secondary**: #88B0D3 (Azul serenidade - confiança)
- **Background**: #F7F4F0 (Creme suave - acolhimento)
- **Accent**: #A8DADC (Verde água - equilíbrio)

### Princípios UX

- **Calma e segurança**: Ambiente visual acolhedor
- **Simplicidade**: Navegação intuitiva para reduzir carga cognitiva
- **Acessibilidade**: Fontes legíveis, contraste adequado
- **Feedback visual**: Validações suaves e não intrusivas

## 🔬 Fundamentação Teórica

### Conceitos Freudianos

- **Lembranças Encobridoras** (1899): Memórias que ocultam experiências significativas
- **Livre Associação**: Método adaptado para interface digital
- **Inconsciente**: Análise de padrões não explícitos nos relatos

### IA na Psicanálise

- **Processamento de Linguagem Natural**: Análise semântica
- **Detecção de Padrões**: Identificação de temas recorrentes
- **Análise de Sentimentos**: Mapeamento emocional

## 🚀 Como Executar

### Desenvolvimento Local

```bash
# Clone o repositório
git clone https://github.com/gabrielmaia/tcc-pimentaa.git
cd tcc-pimentaa

# Execute o projeto
flutter run -d chrome
```

### Build para Web

```bash
flutter build web --base-href /tcc-pimentaa/
```

### Deploy Automático

Push para branch `main` dispara deploy automático no GitHub Pages.

## 📱 Demo

**Web**: https://gabrielmaia.github.io/tcc-pimentaa/

## 🔐 Segurança e Ética

- **LGPD Compliance**: Consentimento explícito, direito ao esquecimento
- **Criptografia**: Todas as lembranças armazenadas com criptografia
- **Anonimização**: IDs únicos sem vinculação a dados pessoais
- **Backup**: Pacientes podem exportar seus dados a qualquer momento

## 📖 Documentação Adicional

- [Fundamentação Teórica](docs/FUNDAMENTACAO_TEORICA.md)
- [Arquitetura do Sistema](docs/ARQUITETURA.md)
- [Guia de Desenvolvimento](docs/DESENVOLVIMENTO.md)
- [Metodologia de Pesquisa](docs/METODOLOGIA.md)

## 👥 Autor

**Gabriel Maia Pimenta**  
TCC - Trabalho de Conclusão de Curso  
Curso: [Inserir Curso]  
Instituição: [Inserir Instituição]  
Orientador: [Inserir Nome]

## 📄 Licença

Este projeto é parte de um TCC acadêmico. Consulte [LICENSE](LICENSE) para mais detalhes.

---

*"O inconsciente é estruturado como uma linguagem"* - Jacques Lacan
