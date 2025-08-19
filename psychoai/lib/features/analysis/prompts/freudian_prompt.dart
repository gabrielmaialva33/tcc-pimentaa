/// Prompts especializados para análise psicanalítica baseada em Freud
class FreudianPrompts {
  /// Prompt principal para análise completa de lembranças
  static String get mainAnalysisPrompt => '''
Você é um assistente especializado em psicanálise freudiana. Analise a seguinte lembrança sob a perspectiva da teoria psicanalítica, especialmente focando no conceito de "lembranças encobridoras" (Deckerinnerungen) de Freud.

INSTRUÇÕES:
1. Mantenha uma abordagem respeitosa e terapêutica
2. Base sua análise em conceitos freudianos estabelecidos
3. Seja empático e não-julgamental
4. Forneça insights construtivos para autoconhecimento
5. Evite diagnósticos ou afirmações categóricas
6. Use linguagem acessível mas tecnicamente precisa

ESTRUTURA DA ANÁLISE:

## 1. CONTEÚDO MANIFESTO
- O que está sendo relatado explicitamente
- Elementos factuais da narrativa
- Contexto temporal e espacial

## 2. POSSÍVEL CONTEÚDO LATENTE
- Significados ocultos potenciais
- Simbolismos presentes
- Conexões inconscientes possíveis

## 3. ANÁLISE DE LEMBRANÇAS ENCOBRIDORAS
- Avaliar se a lembrança pode estar ocultando experiências mais significativas
- Identificar elementos que parecem desproporcionais (muito vívidos para eventos triviais)
- Notar possíveis anacronismos ou inconsistências temporais

## 4. MECANISMOS DE DEFESA IDENTIFICADOS
- Negação: rejeição de realidades dolorosas
- Projeção: atribuição de sentimentos próprios a outros
- Racionalização: justificativas lógicas para atos emocionais
- Sublimação: canalização de impulsos para atividades aceitas
- Repressão: exclusão de conteúdos da consciência

## 5. PADRÕES E REPETIÇÕES
- Temas recorrentes na narrativa
- Padrões comportamentais ou emocionais
- Possíveis compulsões à repetição

## 6. ASPECTOS EMOCIONAIS
- Afetos presentes e ausentes
- Intensidade emocional desproporcional
- Ambivalências identificadas

## 7. SUGESTÕES PARA EXPLORAÇÃO TERAPÊUTICA
- Áreas que merecem investigação mais profunda
- Perguntas que poderiam emergir em sessão
- Conexões com outras experiências de vida

## 8. INSIGHTS PARA AUTOCONHECIMENTO
- Reflexões construtivas baseadas na análise
- Possibilidades de crescimento pessoal
- Compreensões sobre padrões inconscientes

LEMBRANÇA A ANALISAR:
{memory_text}

EMOÇÕES RELATADAS:
{emotions}

INTENSIDADE EMOCIONAL: {intensity}/10

Por favor, forneça uma análise cuidadosa e respeitosa, lembrando que o objetivo é facilitar o autoconhecimento e não estabelecer verdades absolutas sobre a experiência do indivíduo.''';

  /// Prompt para análise rápida focada em padrões
  static String get quickPatternPrompt => '''
Como especialista em psicanálise, identifique brevemente os principais padrões psicológicos nesta lembrança:

FOQUE EM:
- Possíveis lembranças encobridoras
- Mecanismos de defesa principais
- Padrões emocionais
- Sugestões de exploração

LEMBRANÇA: {memory_text}
EMOÇÕES: {emotions}

Forneça uma análise concisa e empática em 3-4 parágrafos.''';

  /// Prompt para detecção específica de lembranças encobridoras
  static String get screenMemoryPrompt => '''
Especialista em teoria freudiana, analise se esta lembrança apresenta características de uma "lembrança encobridora":

CRITÉRIOS FREUDIANOS:
1. Nitidez desproporcional para evento aparentemente trivial
2. Persistência na memória sem justificativa aparente
3. Detalhes vívidos em contraste com esquecimento de eventos importantes
4. Possível função defensiva contra material reprimido
5. Elementos simbólicos que podem representar outros conteúdos

LEMBRANÇA: {memory_text}

Avalie a probabilidade de ser uma lembrança encobridora e explique os indicadores encontrados.''';

  /// Prompt para análise de mecanismos de defesa
  static String get defenseMechanismsPrompt => '''
Identifique os mecanismos de defesa presentes nesta narrativa:

MECANISMOS A INVESTIGAR:
- Negação
- Projeção  
- Racionalização
- Sublimação
- Repressão
- Formação reativa
- Isolamento
- Regressão

LEMBRANÇA: {memory_text}

Para cada mecanismo identificado, explique como se manifesta na narrativa e qual função defensiva pode estar exercendo.''';

  /// Prompt para análise de transferência em relações
  static String get transferencePrompt => '''
Analise possíveis padrões de transferência nas relações descritas nesta lembrança:

FOCAR EM:
- Repetição de padrões relacionais
- Projeção de figuras parentais em outras pessoas
- Expectativas inconscientes em relacionamentos
- Dinâmicas de poder e dependência

LEMBRANÇA: {memory_text}

Identifique como relações passadas podem estar influenciando percepções atuais.''';

  /// Prompt para análise dos sonhos mencionados
  static String get dreamAnalysisPrompt => '''
Se a lembrança menciona sonhos, analise-os sob perspectiva freudiana:

ELEMENTOS DA ANÁLISE DOS SONHOS:
- Conteúdo manifesto vs. latente
- Condensação e deslocamento
- Simbolismo onírico
- Realização de desejos
- Trabalho do sonho

NARRATIVA: {memory_text}

Interprete os elementos oníricos como possível "via régia para o inconsciente".''';

  /// Prompt para síntese terapêutica
  static String get therapeuticSynthesisPrompt => '''
Crie uma síntese terapêutica desta análise psicanalítica:

INTEGRE:
- Insights principais descobertos
- Padrões inconscientes identificados
- Oportunidades de crescimento
- Próximos passos no processo de autoconhecimento

LEMBRANÇA: {memory_text}
ANÁLISES ANTERIORES: {previous_analyses}

Forneça uma síntese empática e orientada para o desenvolvimento pessoal, destacando o que foi mais significativo na análise.''';

  /// Substitui placeholders no prompt com dados reais
  static String fillTemplate(String template, {
    required String memoryText,
    required List<String> emotions,
    required double intensity,
    String? previousAnalyses,
  }) {
    return template
        .replaceAll('{memory_text}', memoryText)
        .replaceAll('{emotions}', emotions.join(', '))
        .replaceAll('{intensity}', intensity.toStringAsFixed(1))
        .replaceAll('{previous_analyses}', previousAnalyses ?? '');
  }

  /// Valida se o texto é adequado para análise
  static ValidationResult validateMemoryText(String text) {
    final trimmedText = text.trim();
    
    if (trimmedText.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Por favor, escreva uma lembrança para análise.',
      );
    }

    if (trimmedText.length < 10) {
      return ValidationResult(
        isValid: false,
        message: 'A lembrança é muito curta. Tente elaborar um pouco mais (mínimo 10 caracteres).',
      );
    }

    if (trimmedText.length > 5000) {
      return ValidationResult(
        isValid: false,
        message: 'A lembrança é muito longa. Tente ser mais conciso.',
      );
    }

    // Verificar conteúdo crítico que requer intervenção imediata
    final criticalKeywords = [
      'quero me matar', 'vou me matar', 'suicidar', 'acabar com minha vida',
      'me cortar', 'me machucar', 'automutilação', 'cortes nos braços',
    ];

    // Verificar conteúdo sensível que pode ser analisado com avisos
    final sensitiveKeywords = [
      'abuso sexual', 'estupro', 'violência sexual', 'molestação',
      'agressão física', 'violência doméstica', 'trauma',
    ];

    final lowerText = trimmedText.toLowerCase();
    
    // Verificar conteúdo crítico primeiro
    for (final keyword in criticalKeywords) {
      if (lowerText.contains(keyword)) {
        return ValidationResult(
          isValid: false,
          message: 'Esta lembrança contém conteúdo que indica risco imediato. '
                   'Por favor, procure ajuda profissional urgente ou ligue 188 (CVV).',
          needsProfessionalHelp: true,
        );
      }
    }
    
    // Verificar conteúdo sensível - permite análise com aviso
    for (final keyword in sensitiveKeywords) {
      if (lowerText.contains(keyword)) {
        return ValidationResult(
          isValid: true, // Permite análise
          message: 'Conteúdo sensível detectado. A análise será feita com cuidado especial. '
                   'Recomendamos discutir com um profissional qualificado.',
          needsProfessionalHelp: false,
          isSensitiveContent: true,
        );
      }
    }

    return ValidationResult(isValid: true);
  }
}

/// Resultado da validação do texto
class ValidationResult {
  final bool isValid;
  final String? message;
  final bool needsProfessionalHelp;
  final bool isSensitiveContent;

  ValidationResult({
    required this.isValid,
    this.message,
    this.needsProfessionalHelp = false,
    this.isSensitiveContent = false,
  });
}

/// Tipos de análise disponíveis
enum AnalysisType {
  complete,
  quickPattern,
  screenMemory,
  defenseMechanisms,
  transference,
  dreamAnalysis;

  String get displayName {
    switch (this) {
      case AnalysisType.complete:
        return 'Análise Completa';
      case AnalysisType.quickPattern:
        return 'Padrões Rápidos';
      case AnalysisType.screenMemory:
        return 'Lembranças Encobridoras';
      case AnalysisType.defenseMechanisms:
        return 'Mecanismos de Defesa';
      case AnalysisType.transference:
        return 'Padrões de Transferência';
      case AnalysisType.dreamAnalysis:
        return 'Análise de Sonhos';
    }
  }
  
  String get prompt {
    switch (this) {
      case AnalysisType.complete:
        return FreudianPrompts.mainAnalysisPrompt;
      case AnalysisType.quickPattern:
        return FreudianPrompts.quickPatternPrompt;
      case AnalysisType.screenMemory:
        return FreudianPrompts.screenMemoryPrompt;
      case AnalysisType.defenseMechanisms:
        return FreudianPrompts.defenseMechanismsPrompt;
      case AnalysisType.transference:
        return FreudianPrompts.transferencePrompt;
      case AnalysisType.dreamAnalysis:
        return FreudianPrompts.dreamAnalysisPrompt;
    }
  }
}