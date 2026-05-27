import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enade_app/core/theme/app_theme.dart';
import '../../../data/local/local_storage_service.dart';

/// [LoginScreen]
/// Tela inicial de autenticação do aplicativo ENADE Tech.
/// É um StatefulWidget porque precisamos gerenciar estados locais como 
/// o carregamento (loading) da requisição, visibilidade da senha e os dados dos campos de texto.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar o texto digitado pelo usuário.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Variáveis de estado para controle de UI.
  /// [_isLoading] bloqueia o botão e exibe um spinner enquanto a requisição de login está em andamento.
  bool _isLoading = false;
  /// [_obscurePassword] alterna a visibilidade dos caracteres no campo de senha.
  bool _obscurePassword = true;

  /// O método [dispose] é crucial para liberar recursos da memória quando a tela é destruída,
  /// evitando "memory leaks" (vazamentos de memória) causados pelos controllers.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Método responsável por realizar a autenticação do usuário.
  /// Comunica-se com o Supabase, trata o retorno e gerencia o armazenamento local de metadados.
  Future<void> _signIn() async {
    // Atualiza o estado para mostrar o indicador de carregamento
    setState(() => _isLoading = true);
    
    try {
      // Tenta realizar o login usando a instância do Supabase.
      // O .trim() é usado para remover espaços em branco acidentais antes ou depois do texto.
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Extração de dados do usuário:
      // Busca o nome salvo nos metadados do Supabase e persiste localmente.
      // Isso evita ter que fazer requisições extras ao banco só para exibir o nome do usuário na Home.
      final user = response.user;
      if (user != null) {
        final name = user.userMetadata?['display_name'] as String?;
        if (name != null && name.isNotEmpty) {
          await LocalStorageService.saveDisplayName(name);
        }
      }

      // Verifica se o widget ainda está montado na árvore de widgets antes de navegar.
      // Isso previne erros caso o usuário feche o app ou volte a tela antes da requisição terminar.
      if (mounted) {
        // pushReplacementNamed substitui a rota atual, impedindo que o usuário 
        // volte para a tela de login pelo botão de "voltar" do celular.
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (error) {
      // Captura qualquer erro de autenticação (senha errada, usuário não encontrado, sem internet)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao fazer login: dados incorretos.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // O bloco finally é executado independentemente de sucesso ou erro.
      // Removemos o estado de loading para liberar a interface.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Preenche toda a largura da tela e aplica o gradiente padrão definido no AppTheme
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.descendingBlue),
        
        // SafeArea garante que o conteúdo não fique escondido sob o notch ou barra de status do celular
        child: SafeArea(
          // SingleChildScrollView permite que a tela role, evitando o erro de "overflow" 
          // (pixels estourados na tela) quando o teclado virtual sobe.
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- SEÇÃO DE CABEÇALHO (Logo e Títulos) ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school_rounded, size: 72, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ENADE Tech',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Prepare-se para o sucesso',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 48),

                  // --- SEÇÃO DE FORMULÁRIO (Card de Login) ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Bem-vindo de volta 👋',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        
                        // Campo de E-mail construído através de um método auxiliar para evitar código duplicado
                        _buildTextField(
                          controller: _emailController,
                          hint: 'E-mail',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        
                        // Campo de Senha
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Senha',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          // Botão interativo para mostrar/ocultar a senha
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
                        
                        // Botão de Ação: Alterna entre o indicador de progresso e o botão de "Entrar"
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryDark,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                        const SizedBox(height: 14),
                        
                        // Link de navegação para a tela de registro
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'Não tem uma conta? Cadastre-se',
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

  /// Método auxiliar para construir os campos de texto ([TextField]) de forma padronizada.
  /// Reduz a duplicação de código e centraliza o design (bordas, cores, preenchimento).
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
          borderSide: BorderSide.none, // Remove a borda padrão para manter o visual limpo
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}