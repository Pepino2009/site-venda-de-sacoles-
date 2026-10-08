import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Erro ao inicializar Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canndy Ice - Sacolés Gourmet',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const TelaBoasVindasLogin(),
    );
  }
}

void _mostrarContatoWhatsApp(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Dúvidas? Fale Conosco 📱'),
      content: const Text('Chame no WhatsApp do Atendimento:\n\n(49) 99166-9124'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}

// 1. TELA DE BOAS-VINDAS E LOGIN
class TelaBoasVindasLogin extends StatefulWidget {
  const TelaBoasVindasLogin({Key? key}) : super(key: key);

  @override
  _TelaBoasVindasLoginState createState() => _TelaBoasVindasLoginState();
}

class _TelaBoasVindasLoginState extends State<TelaBoasVindasLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaOculta = true;
  bool _carregando = false;

  void _entrar() async {
    String email = _emailController.text.trim().toLowerCase();
    String senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o e-mail e a senha!')),
      );
      return;
    }

    // Acesso do Dono
    if (email == 'williamluizgusatti@gmail.com') {
      if (senha == '123') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaPainelDono()),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha incorreta para o administrador!')),
        );
        return;
      }
    }

    setState(() => _carregando = true);

    try {
      // Verifica o utilizador no Firestore
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(email).get();

      setState(() => _carregando = false);

      if (!doc.exists) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Conta não encontrada ⚠️'),
            content: const Text('Este e-mail ainda não possui cadastro. Por favor, clique em "Cadastre-se aqui" para criar sua conta.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      } else {
        String senhaSalva = doc.data()?['senha'] ?? '';
        if (senhaSalva == senha) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TelaCatalogo(clienteEmail: email)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha incorreta! Tente novamente.')),
          );
        }
      }
    } catch (e) {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 180,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.icecream, size: 64, color: Colors.pinkAccent);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bem-vindo ao\nCanndy Ice!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'O melhor site de vendas de sacolés gourmet da região. Faça seu pedido com facilidade!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _senhaController,
                    obscureText: _senhaOculta,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaOculta ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _senhaOculta = !_senhaOculta;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _carregando
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _entrar,
                          child: const Text('Entrar no Sistema', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaCadastro()),
                      );
                    },
                    child: const Text('Não tem uma conta? Cadastre-se aqui', style: TextStyle(color: Colors.pinkAccent)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 2. TELA DE REGISTRO / CRIAR CONTA
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({Key? key}) : super(key: key);

  @override
  _TelaCadastroState createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaOcultaCadastro = true;
  bool _carregando = false;

  void _cadastrar() async {
    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim().toLowerCase();
    String senha = _senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos para se cadastrar!')),
      );
      return;
    }

    if (email == 'williamluizgusatti@gmail.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este e-mail é reservado para o administrador.')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final firestore = FirebaseFirestore.instance;
      
      var docExistente = await firestore.collection('usuarios').doc(email).get();
      if (docExistente.exists) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este e-mail já está cadastrado!')),
        );
        return;
      }

      await firestore.collection('usuarios').doc(email).set({
        'nome': nome,
        'email': email,
        'senha': senha,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      setState(() => _carregando = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Conta Criada com Sucesso! 🎉'),
          content: const Text('Seu cadastro foi salvo na nuvem permanentemente. Agora você já pode fazer o login.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Nova Conta - Canndy Ice'), backgroundColor: Colors.pink),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add, size: 54, color: Colors.pinkAccent),
                  const SizedBox(height: 12),
                  const Text('Cadastre-se', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _senhaController,
                    obscureText: _senhaOcultaCadastro,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaOcultaCadastro ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _senhaOcultaCadastro = !_senhaOcultaCadastro;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _carregando
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _cadastrar,
                          child: const Text('Finalizar Cadastro', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 3. PAINEL DO DONO
class TelaPainelDono extends StatelessWidget {
  const TelaPainelDono({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel de Produção - Canndy Ice'),
          backgroundColor: Colors.purple,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.hourglass_empty), text: '1. Pendentes (Aprovar)'),
              Tab(icon: Icon(Icons.kitchen), text: '2. Para Ser Feito'),
              Tab(icon: Icon(Icons.task_alt), text: '3. Histórico / Entregues'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Sair',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaBoasVindasLogin()),
                );
              },
            )
          ],
        ),
        body: const TabBarView(
          children: [
            AbaListaPedidosFirestore(tipoAba: 'Pendente'),
            AbaListaPedidosFirestore(tipoAba: 'Para Fazer'),
            AbaListaPedidosFirestore(tipoAba: 'Historico'),
          ],
        ),
      ),
    );
  }
}

class AbaListaPedidosFirestore extends StatelessWidget {
  final String tipoAba;

  const AbaListaPedidosFirestore({Key? key, required this.tipoAba}) : super(key: key);

  void _atualizarStatus(BuildContext context, String docId, String novoStatus) async {
    await FirebaseFirestore.instance.collection('pedidos').doc(docId).update({
      'status': novoStatus,
    });
  }

  void _atualizarComMotivo(BuildContext context, String docId, String novoStatus) {
    final _motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Pedido (Dono)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Informe o motivo do cancelamento para avisar o cliente:'),
            const SizedBox(height: 12),
            TextField(
              controller: _motivoController,
              decoration: const InputDecoration(labelText: 'Ex: Produto esgotado', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (_motivoController.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection('pedidos').doc(docId).update({
                'status': novoStatus,
                'motivoCancelamento': _motivoController.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text('Confirmar Cancelamento', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deletarPedido(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Pedido 🗑️'),
        content: const Text('Tem certeza que deseja apagar este pedido permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('pedidos').doc(docId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pedido excluído com sucesso!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pedidos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum pedido no sistema.', style: TextStyle(fontSize: 16, color: Colors.grey)));
        }

        var todosPedidos = snapshot.data!.docs;

        var listaFiltrada = todosPedidos.where((doc) {
          var dados = doc.data() as Map<String, dynamic>;
          String status = dados['status'] ?? 'Pendente';
          if (tipoAba == 'Pendente') {
            return status == 'Pendente';
          } else if (tipoAba == 'Para Fazer') {
            return status == 'Aprovado / Para Fazer';
          } else {
            return status == 'Entregue' || status.contains('Cancelado') || status == 'Recusado';
          }
        }).toList();

        if (listaFiltrada.isEmpty) {
          String mensagemVazia = 'Nenhum pedido nesta seção.';
          if (tipoAba == 'Pendente') mensagemVazia = 'Nenhum pedido pendente de aprovação.';
          if (tipoAba == 'Para Fazer') mensagemVazia = 'Nenhum pedido na fila de produção no momento!';
          if (tipoAba == 'Historico') mensagemVazia = 'Nenhum pedido no histórico.';

          return Center(
            child: Text(mensagemVazia, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }

        return ListView.builder(
          itemCount: listaFiltrada.length,
          itemBuilder: (context, index) {
            var doc = listaFiltrada[index];
            var pedido = doc.data() as Map<String, dynamic>;
            String docId = doc.id;
            String status = pedido['status'] ?? 'Pendente';

            Color corStatus = Colors.orange;
            if (status == 'Aprovado / Para Fazer') corStatus = Colors.blue;
            if (status == 'Entregue') corStatus = Colors.green;
            if (status.contains('Cancelado') || status == 'Recusado') corStatus = Colors.red;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${pedido['cliente']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Row(
                          children: [
                            Chip(
                              label: Text(status, style: const TextStyle(color: Colors.white)),
                              backgroundColor: corStatus,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                              tooltip: 'Excluir Pedido',
                              onPressed: () => _deletarPedido(context, docId),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Total: R\$ ${(pedido['total'] ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                    Text('WhatsApp: ${pedido['telefone']}'),
                    Text('Itens: ${pedido['detalhes']}'),
                    if (pedido['observacao'] != null && pedido['observacao'].toString().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(6),
                        color: Colors.yellow.shade100,
                        child: Text('Obs do Cliente: ${pedido['observacao']}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      ),
                    Text('Entrega: ${pedido['data']}'),
                    if (pedido['motivoCancelamento'] != null && pedido['motivoCancelamento'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('Motivo: ${pedido['motivoCancelamento']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    
                    const Divider(height: 20),

                    if (tipoAba == 'Pendente') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: const Text('Recusar', style: TextStyle(color: Colors.white)),
                            onPressed: () => _atualizarComMotivo(context, docId, 'Recusado'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Aprovar (Fazer)', style: TextStyle(color: Colors.white)),
                            onPressed: () => _atualizarStatus(context, docId, 'Aprovado / Para Fazer'),
                          ),
                        ],
                      ),
                    ] else if (tipoAba == 'Para Fazer') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                            icon: const Icon(Icons.done_all, color: Colors.white),
                            label: const Text('Marcar como Entregue', style: TextStyle(color: Colors.white)),
                            onPressed: () => _atualizarStatus(context, docId, 'Entregue'),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Center(
                        child: Text('Pedido finalizado.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 4. TELA DE CATÁLOGO
class TelaCatalogo extends StatefulWidget {
  final String clienteEmail;

  const TelaCatalogo({Key? key, required this.clienteEmail}) : super(key: key);

  @override
  _TelaCatalogoState createState() => _TelaCatalogoState();
}

class _TelaCatalogoState extends State<TelaCatalogo> {
  final List<Map<String, dynamic>> produtos = [
    {
      'nome': 'Sacolé de Ninho com Nutella',
      'preco': 10.00,
      'qtd': 0,
      'imagem': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ3RTXEM3Cu4AkujefDfh4M6k7nADW6cs_kg0KG_MCnwA&s=10',
    },
    {
      'nome': 'Sacolé de Morango Cremoso',
      'preco': 7.00,
      'qtd': 0,
      'imagem': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCjJIERHj3rhitAX6YJDZozEsVGshto4Ct5xNSfp7z6A&s=10',
    },
    {
      'nome': 'Sacolé de Chocolate Gourmet',
      'preco': 7.00,
      'qtd': 0,
      'imagem': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOnEvc2x9EIKUF0uWw8H8ZQOxW-g10fhyDrSRGKgL7Mjh8F-2XXB3lkKc&s=10',
    },
    {
      'nome': 'Sacolé de Coco com Doce de Leite',
      'preco': 6.50,
      'qtd': 0,
      'imagem': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDoOzY3rgkndQZDFqOsOynonwcLZahnN5lsrS7RjAtHg&s=10',
    },
  ];

  double get valorTotal {
    double total = 0;
    for (var p in produtos) {
      total += (p['preco'] * p['qtd']);
    }
    return total;
  }

  int get totalItens {
    int total = 0;
    for (var p in produtos) {
      total += (p['qtd'] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canndy Ice - Catálogo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'Dúvidas no WhatsApp',
            onPressed: () => _mostrarContatoWhatsApp(context),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Meus Pedidos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaMeusPedidos(clienteEmail: widget.clienteEmail),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TelaBoasVindasLogin()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                var produto = produtos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            produto['imagem'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.icecream, size: 50, color: Colors.pinkAccent),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(produto['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('R\$ ${produto['preco'].toStringAsFixed(2)}', style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  if (produto['qtd'] > 0) produto['qtd']--;
                                });
                              },
                            ),
                            Text('${produto['qtd']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  if (produto['qtd'] < 10) {
                                    produto['qtd']++;
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Limite máximo de 10 unidades por sabor!')),
                                    );
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.pink.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total de itens: $totalItens', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Valor: R\$ ${valorTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  onPressed: totalItens == 0
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaPedidoForm(
                                produtosSelecionados: produtos.where((p) => p['qtd'] > 0).toList(),
                                valorTotal: valorTotal,
                                clienteEmail: widget.clienteEmail,
                              ),
                            ),
                          );
                        },
                  child: const Text('Avançar / Agendar', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 5. TELA "MEUS PEDIDOS"
class TelaMeusPedidos extends StatelessWidget {
  final String clienteEmail;

  const TelaMeusPedidos({Key? key, required this.clienteEmail}) : super(key: key);

  void _cancelarPedidoCliente(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('pedidos').doc(docId).update({
      'status': 'Cancelado pelo Cliente',
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seu pedido foi cancelado com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos - Canndy Ice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'Dúvidas no WhatsApp',
            onPressed: () => _mostrarContatoWhatsApp(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('clienteEmail', isEqualTo: clienteEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Você ainda não fez nenhum pedido.', style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          var meusPedidos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: meusPedidos.length,
            itemBuilder: (context, index) {
              var doc = meusPedidos[index];
              var pedido = doc.data() as Map<String, dynamic>;
              String docId = doc.id;
              String status = pedido['status'] ?? 'Pendente';

              Color corStatus = Colors.orange;
              if (status == 'Aprovado / Para Fazer') corStatus = Colors.blue;
              if (status == 'Entregue') corStatus = Colors.green;
              if (status.contains('Cancelado') || status == 'Recusado') corStatus = Colors.red;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pedido de ${pedido['cliente']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Chip(
                            label: Text(status, style: const TextStyle(color: Colors.white)),
                            backgroundColor: corStatus,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Itens: ${pedido['detalhes']}'),
                      if (pedido['observacao'] != null && pedido['observacao'].toString().isNotEmpty)
                        Text('Sua Obs: ${pedido['observacao']}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
                      Text('Valor Total: R\$ ${(pedido['total'] ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
                      Text('Data de Entrega: ${pedido['data']}'),
                      
                      if (pedido['motivoCancelamento'] != null && pedido['motivoCancelamento'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('Motivo do Dono: ${pedido['motivoCancelamento']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),

                      if (status == 'Pendente') ...[
                        const Divider(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Cancelar Pedido'),
                            onPressed: () => _cancelarPedidoCliente(context, docId),
                          ),
                        ),
                      ] else ...[
                        const Divider(height: 20),
                        const Center(
                          child: Text('Este pedido não pode mais ser cancelado.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12)),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 6. TELA DE FORMULÁRIO DE PEDIDO
class TelaPedidoForm extends StatefulWidget {
  final List<Map<String, dynamic>> produtosSelecionados;
  final double valorTotal;
  final String clienteEmail;

  const TelaPedidoForm({Key? key, required this.produtosSelecionados, required this.valorTotal, required this.clienteEmail}) : super(key: key);

  @override
  _TelaPedidoFormState createState() => _TelaPedidoFormState();
}

class _TelaPedidoFormState extends State<TelaPedidoForm> {
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _dataController = TextEditingController();
  final _obsController = TextEditingController();
  bool _carregando = false;

  void _enviarPedido() async {
    if (_nomeController.text.isEmpty || _telefoneController.text.isEmpty || _dataController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome, telefone e a data de entrega!')),
      );
      return;
    }

    setState(() => _carregando = true);

    String detalhesItens = widget.produtosSelecionados
        .map((p) => '${p['qtd']}x ${p['nome']}')
        .join(', ');

    try {
      await FirebaseFirestore.instance.collection('pedidos').add({
        'clienteEmail': widget.clienteEmail,
        'cliente': _nomeController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'detalhes': detalhesItens,
        'observacao': _obsController.text.trim(),
        'total': widget.valorTotal,
        'data': _dataController.text.trim(),
        'status': 'Pendente',
        'motivoCancelamento': '',
        'criadoEm': FieldValue.serverTimestamp(),
      });

      setState(() => _carregando = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pedido Enviado com Sucesso! ⏳'),
          content: const Text('Seu pedido foi salvo na nuvem!\nAguarde até 5 horas úteis para receber a confirmação. Acompanhe o status na aba "Meus Pedidos".'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Agendamento - Canndy Ice')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text('Resumo do Pedido:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...widget.produtosSelecionados.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('• ${p['qtd']}x ${p['nome']} (R\$ ${(p['preco'] * p['qtd']).toStringAsFixed(2)})'),
            )),
            const Divider(height: 30),
            Text('Valor Total: R\$ ${widget.valorTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink)),
            const SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Seu Nome Completo', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Seu WhatsApp / Telefone', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dataController,
              decoration: const InputDecoration(
                labelText: 'Dia da Entrega (Ex: Quarta-feira - 07/10)',
                helperText: 'Dias de entrega disponíveis: Segundas, Quartas e Sextas.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _obsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações / Preferências (Opcional)',
                hintText: 'Ex: Remover algum ingrediente, caprichar mais, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            _carregando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
                    onPressed: _enviarPedido,
                    child: const Text('Enviar Pedido para Aprovação', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
          ],
        ),
      ),
    );
  }
}