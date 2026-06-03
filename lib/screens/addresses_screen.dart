import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/address_controller.dart';
import '../controllers/item_controller.dart';
import '../models/address.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  bool _showAddForm = false;
  final _formKey = GlobalKey<FormState>();

  final _aliasController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  bool _isLoadingCep = false;

  @override
  void initState() {
    super.initState();
    // Busca os endereços já cadastrados ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressController>().fetchAddresses();
    });
  }

  /// Busca endereço baseado no CEP digitado (quando atinge 8 dígitos)
  Future<void> _onCepChanged(String value) async {
    final cleanCep = value.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length == 8) {
      setState(() => _isLoadingCep = true);
      try {
        final address = await context.read<ItemController>().fetchAddressFromCep(cleanCep);
        if (address != null && mounted) {
          setState(() {
            _streetController.text = address['logradouro'] ?? '';
            _neighborhoodController.text = address['bairro'] ?? '';
            _cityController.text = address['localidade'] ?? '';
            _stateController.text = address['uf'] ?? '';
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CEP não encontrado ou inválido.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao buscar informações do CEP.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoadingCep = false);
        }
      }
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final addressController = context.read<AddressController>();

    final user = authController.userProfile;
    if (user == null) return;

    final success = await addressController.addAddress(
      userId: user.id,
      alias: _aliasController.text.trim().isEmpty ? null : _aliasController.text.trim(),
      cep: _cepController.text.trim(),
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      complement: _complementController.text.trim().isEmpty ? null : _complementController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço salvo com sucesso!'), backgroundColor: Colors.green),
        );
        _clearForm();
        setState(() => _showAddForm = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${addressController.error}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _clearForm() {
    _aliasController.clear();
    _cepController.clear();
    _streetController.clear();
    _numberController.clear();
    _complementController.clear();
    _neighborhoodController.clear();
    _cityController.clear();
    _stateController.clear();
  }

  void _confirmDeleteAddress(Address address) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Excluir Endereço', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Tem certeza que deseja excluir o endereço "${address.alias ?? address.street}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await context.read<AddressController>().removeAddress(address.id!);
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Endereço excluído!'), backgroundColor: Colors.green),
                    );
                  } else {
                    final err = context.read<AddressController>().error;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir: $err'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressController = context.watch<AddressController>();
    final addresses = addressController.addresses;
    final isLoading = addressController.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9DB),
      appBar: AppBar(
        title: const Text('Meus Endereços', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFFFF9DB),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Alternador entre lista e formulário de adição
              AnimatedCrossFade(
                firstChild: _buildAddressList(addresses, isLoading),
                secondChild: _buildAddAddressForm(),
                crossFadeState: _showAddForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              const SizedBox(height: 24),
              if (!_showAddForm)
                ElevatedButton.icon(
                  onPressed: () => setState(() => _showAddForm = true),
                  icon: const Icon(Icons.add),
                  label: const Text('Cadastrar Novo Endereço', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressList(List<Address> addresses, bool isLoading) {
    if (isLoading && addresses.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Colors.black87)),
      );
    }

    if (addresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.location_off_outlined, size: 64, color: Colors.black38),
            SizedBox(height: 16),
            Text(
              'Nenhum endereço cadastrado.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: addresses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final address = addresses[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFFF9DB),
              child: Icon(
                address.alias?.toLowerCase() == 'trabalho'
                    ? Icons.work_outline
                    : Icons.home_outlined,
                color: Colors.black87,
              ),
            ),
            title: Text(
              address.alias ?? 'Endereço ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${address.street}, ${address.number}${address.complement != null ? ' - ${address.complement}' : ''}\n${address.neighborhood}, ${address.city} - ${address.state}\nCEP: ${address.cep}',
                style: const TextStyle(height: 1.3, color: Colors.black54),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteAddress(address),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddAddressForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cadastrar Endereço',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _clearForm();
                    setState(() => _showAddForm = false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aliasController,
              decoration: const InputDecoration(
                labelText: 'Identificação (Apelido)',
                hintText: 'Ex: Casa, Trabalho, Apartamento',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cepController,
              decoration: InputDecoration(
                labelText: 'CEP',
                hintText: '00000-000',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: _isLoadingCep
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                        ),
                      )
                    : null,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: _onCepChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'CEP é obrigatório';
                if (value.replaceAll(RegExp(r'\D'), '').length != 8) return 'CEP deve ter 8 dígitos';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(labelText: 'Rua / Logradouro'),
              validator: (value) => value!.trim().isEmpty ? 'Rua é obrigatória' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      labelText: 'Número',
                      hintText: '123 ou S/N',
                    ),
                    validator: (value) => value!.trim().isEmpty ? 'Número é obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _complementController,
                    decoration: const InputDecoration(
                      labelText: 'Complemento',
                      hintText: 'Apto, Bloco',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _neighborhoodController,
              decoration: const InputDecoration(labelText: 'Bairro'),
              validator: (value) => value!.trim().isEmpty ? 'Bairro é obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Cidade'),
                    validator: (value) => value!.trim().isEmpty ? 'Cidade é obrigatória' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(labelText: 'UF'),
                    validator: (value) => value!.trim().isEmpty ? 'UF obrigatória' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _clearForm();
                      setState(() => _showAddForm = false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }
}
