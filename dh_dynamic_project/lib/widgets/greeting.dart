import 'package:flutter/material.dart';
import 'package:daggerheart_dynamic/core/theme/app_pallete.dart';
import 'package:daggerheart_dynamic/providers/theme_provider.dart';
import 'package:provider/provider.dart';

/// Um widget que permite mostrar uma saudação personalizada usando RichText.
///
/// Esse Widget permite mostrar de maneira dinâmica uma mensagem de saudação personalizada
/// que pode conter um nome de usuário em qualquer ponto da mensagem, se o nome de usuário
/// estiver indisponível ele mostra um indicador de progresso ao invés disso.
///
/// Greeting() recebe três parâmetros: uma string (userNameText) contendo o nome do usuário,
/// uma string (message) contendo uma mensagem personalizada, e um TextStyle (style) que
/// permite estilização externa do texto. O nome do usuário não é obrigatório e pode ser "null".
///
/// O widget procura pelo padrão "{{userName}}" dentro da string "message", caso um nome
/// de usuário seja providenciado o padrão será substituído pelo nome do usuário (userNameText),
/// caso (userNameText) seja nulo, o padrão será substituído por um indicador de progresso.
///
/// Exemplos de uso:
/// ```dart
/// Greeting(
///   message: "Bem vindo(a) {{userName}}!, {{userName}} é muito legal!",
///   userNameText: 'Fulano da Silva',
/// )
///
/// output: "Bem vindo(a) Fulano da Silva!, Fulano da Silva é muito legal!"
/// ```
///
/// Caso o padrão não exista na string o widget retorna um RichText contendo a string passada em (message).
/// ```dart
/// Greeting(
///   message: "Só sei que nada sei!",
/// )
///
/// output: "Só sei que nada sei!"
/// ```
///
/// Caso o padrão exista na string, mas (userNameText == null), um linearProgressIndicator aparece em seu lugar.
/// ```dart
/// Greeting(
///   message: "Essa barra significa que o nome de usuário não está disponível: {{userName}}",
///   userNameText: null,
/// )
///
/// output: "Essa barra significa que o nome de usuário não está disponível: [linearProgressIndicator()]"
/// ```
///

class Greeting extends StatelessWidget {
  final String? userNameText;
  final String message;
  final TextStyle? style;
  final double progressIndicatorSize;

  //constructor
  const Greeting({
    super.key,
    this.userNameText,
    required this.message,
    this.style,
    this.progressIndicatorSize = 65,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    RegExp pattern = RegExp(r'(?<!\{)\{(?=\{userName\})|\}(?!\})');
    List<InlineSpan> spans = [];
    List<String> parts = message.split(pattern);

    for (int i = 0; i < parts.length; i++) {
      if (parts[i] != '{userName}') {
        spans.add(TextSpan(text: parts[i]));
      } else {
        spans.add(
          userNameText == null
              ? WidgetSpan(
                  child: SizedBox(
                    height: 3,
                    width: progressIndicatorSize,
                    child: LinearProgressIndicator(
                      backgroundColor: themeProvider.isDarkModeOn
                          ? Pallete.primaryOnLight
                          : Pallete.primaryOnDark,
                      color: themeProvider.isDarkModeOn
                          ? Pallete.primaryOnDark
                          : Pallete.primaryOnLight,
                    ),
                  ),
                )
              : TextSpan(
                  text: userNameText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: style ?? DefaultTextStyle.of(context).style,
      ),
    );
  }
}
