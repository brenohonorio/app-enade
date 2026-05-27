import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

/// [RegisterScreen]
/// Tela responsável pelo cadastro de novos usuários no aplicativo ENADE Tech.
/// Utiliza um StatefulWidget para gerenciar o estado dos campos de texto, 
/// visibilidade da senha e o estado de carregamento durante a requisição.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para capturar os dados inseridos pelo usuário.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Variáveis de controle de estado da interface.
  /// [_isLoading] exibe o indicador de progresso e desabilita o botão durante o cadastro.
  bool _isLoading = false;
  /// [_obscurePassword] controla se a senha digitada está oculta (pontinhos) ou visível.
  bool _obscurePassword = true;

  /// Libera os recursos da memória assim que a tela for fechada ou destruída.
  /// Essencial para evitar vazamentos de memória (memory leaks) com os controllers.
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Método responsável por validar os dados e registrar o usuário no Supabase.
  Future<void> _signUp() async {
    // Captura os textos e remove espaços vazios nas extremidades
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validação inicial simples: garante que o usuário digitou um nome.
    // O Supabase já faz a validação de formato de e-mail e tamanho mínimo de senha nativamente.
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe seu nome.'),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Interrompe a execução se o nome estiver vazio
    }

    setState(() => _isLoading = true);
    
    try {
      // Realiza o cadastro no Supabase.
      // O campo 'data' é usado para salvar metadados extras do usuário (neste caso, o nome).
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );

      // ESTRATÉGIA DE FLUXO: Faz logout imediato após o cadastro.
      // Isso é feito para forçar o usuário a passar pela tela de login padrão.
      // É útil também caso o projeto exija confirmação de e-mail no futuro, 
      // evitando que o usuário ganhe uma sessão ativa sem ter confirmado a conta.
      await Supabase.instance.client.auth.signOut();

      // Se o widget ainda estiver ativo na tela, mostra o sucesso e redireciona.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Faça login.'),
            backgroundColor: Colors.green,
          ),
        );
        // Retorna para a tela de login substituindo a rota atual
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (error) {
      // Captura e exibe erros retornados pelo Supabase (ex: e-mail já cadastrado, senha fraca).
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Garante que o loading seja desativado ao final, independentemente de sucesso ou falha.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Preenche toda a área disponível com o gradiente do tema do app
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.descendingBlue),
        child: SafeArea(
          // Permite rolagem da tela para não quebrar o layout quando o teclado aparecer
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- CABEÇALHO ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_rounded, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Criar Conta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Comece sua jornada ENADE',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // --- FORMULÁRIO DE CADASTRO ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campo Nome (Aplica letra maiúscula automaticamente no início de cada palavra)
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Seu nome',
                          icon: Icons.badge_outlined,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 14),
                        
                        // Campo E-mail
                        _buildTextField(
                          controller: _emailController,
                          hint: 'E-mail',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        
                        // Campo Senha com botão de alternância de visibilidade
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Senha (mínimo 6 caracteres)',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white54,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // Botão de Cadastrar ou Loading
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : ElevatedButton(
                                onPressed: _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryDark,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: const Text('Cadastrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                        const SizedBox(height: 14),
                        
                        // Botão para voltar à tela de Login
                        TextButton(
                          // Navigator.pop remove esta tela da pilha, voltando suavemente para a tela de Login
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Já tem uma conta? Voltar',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Método auxiliar construtor de [TextField] personalizado.
  /// Permite reaproveitar a UI de inputs mantendo o design do app limpo e consistente.
  /// Adicionado o parâmetro [textCapitalization] em relação à tela de login, 
  /// permitindo formatações nativas do teclado, como iniciar palavras com maiúsculas para o campo de Nome.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}