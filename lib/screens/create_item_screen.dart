import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/item_controller.dart';
import '../controllers/address_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/address.dart';
import '../widgets/image_source_sheet.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    
    // Substitui ponto por vírgula visualmente para o usuário brasileiro
    String newText = newValue.text.replaceAll('.', ',');
    
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CreateItemScreen extends StatefulWidget {
  const CreateItemScreen({super.key});

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();

  // Campos de Endereço (ViaCEP)
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  // Gerenciamento de Endereços
  final _addressAliasController = TextEditingController();
  Address? _selectedSavedAddress;
  bool _isCreatingNewAddress = true;
  bool _saveToFavorites = true;

  bool _isLoadingCep = false;

  @override
  void initState() {
    super.initState();
    // Busca endereços existentes para o usuário
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final addressController = context.read<AddressController>();
      await addressController.fetchAddresses();
      if (addressController.addresses.isNotEmpty && mounted) {
        setState(() {
          _selectedSavedAddress = addressController.addresses.first;
          _isCreatingNewAddress = false;
        });
      }
    });
  }

  String _selectedCondition = 'Usado - Em bom estado';
  final List<String> _conditions = [
    'Novo',
    'Usado - Como novo',
    'Usado - Em bom estado',
    'Usado - Com marcas de uso',
    'Para Doação'
  ];

  bool _isFree = false;
  File? _imageFile;

  /// Abre o seletor para escolher entre tirar foto com a Câmera ou buscar na Galeria
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ImageSourceSheet(
        onSourceSelected: (source) async {
          final pickedFile = await _picker.pickImage(
            source: source,
            imageQuality: 80,
            maxWidth: 1024,
          );
          if (pickedFile != null) {
            setState(() {
              _imageFile = File(pickedFile.path);
            });
          }
        },
      ),
    );
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

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, adicione pelo menos uma foto do item.')),
      );
      return;
    }

    if (!_isCreatingNewAddress && _selectedSavedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um endereço cadastrado.')),
      );
      return;
    }

    final itemController = context.read<ItemController>();
    final double price = _isFree ? 0.0 : (double.tryParse(_priceController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0);

    final cep = _isCreatingNewAddress ? _cepController.text.trim() : _selectedSavedAddress?.cep;
    final street = _isCreatingNewAddress ? _streetController.text.trim() : _selectedSavedAddress?.street;
    final neighborhood = _isCreatingNewAddress ? _neighborhoodController.text.trim() : _selectedSavedAddress?.neighborhood;
    final city = _isCreatingNewAddress ? _cityController.text.trim() : _selectedSavedAddress?.city;
    final state = _isCreatingNewAddress ? _stateController.text.trim() : _selectedSavedAddress?.state;
    final number = _isCreatingNewAddress ? _numberController.text.trim() : _selectedSavedAddress?.number;
    final complement = _isCreatingNewAddress ? _complementController.text.trim() : _selectedSavedAddress?.complement;

    // Se selecionou cadastrar novo e salvar em favoritos, salva primeiro
    if (_isCreatingNewAddress && _saveToFavorites) {
      final authController = context.read<AuthController>();
      final user = authController.userProfile;
      if (user != null) {
        await context.read<AddressController>().addAddress(
          userId: user.id,
          alias: _addressAliasController.text.trim().isEmpty ? null : _addressAliasController.text.trim(),
          cep: cep!,
          street: street!,
          number: number!,
          complement: complement?.isEmpty == true ? null : complement,
          neighborhood: neighborhood!,
          city: city!,
          state: state!,
        );
      }
    }

    final success = await itemController.createItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      condition: _selectedCondition,
      contactInfo: _contactController.text.trim(),
      imageFile: _imageFile,
      cep: cep,
      street: street,
      neighborhood: neighborhood,
      city: city,
      state: state,
      number: number,
      complement: complement,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anúncio publicado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${itemController.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
            action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ItemController, bool>((ctrl) => ctrl.isLoading);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9DB),
      appBar: AppBar(
        title: const Text('Novo Anúncio', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFFFF9DB),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Picker Area
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      image: _imageFile != null
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text('Adicionar fotos (Câmera ou Galeria)', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações Básicas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'O que você está vendendo/doando?',
                          hintText: 'Ex: Bicicleta Caloi 10',
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'Título é obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCondition,
                        decoration: const InputDecoration(labelText: 'Condição do item'),
                        items: _conditions.map((String condition) {
                          return DropdownMenuItem<String>(
                            value: condition,
                            child: Text(condition),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCondition = newValue!;
                            if (_selectedCondition == 'Para Doação') {
                              _isFree = true;
                              _priceController.clear();
                            } else {
                              _isFree = false;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição detalhada',
                          hintText: 'Descreva o estado, tempo de uso, etc.',
                        ),
                        maxLines: 3,
                        validator: (value) => value!.trim().isEmpty ? 'Descrição é obrigatória' : null,
                      ),
                      const SizedBox(height: 16),

                      CheckboxListTile(
                        title: const Text('É uma doação (Grátis)'),
                        value: _isFree,
                        activeColor: Colors.black87,
                        onChanged: (bool? value) {
                          setState(() {
                            _isFree = value ?? false;
                            if (_isFree) {
                              _priceController.clear();
                              _selectedCondition = 'Para Doação';
                            } else {
                               if(_selectedCondition == 'Para Doação') {
                                 _selectedCondition = 'Usado - Em bom estado';
                               }
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      if (!_isFree) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Preço (R\$)',
                            prefixText: 'R\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            CurrencyInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Preço é obrigatório';
                            if (double.tryParse(value.replaceAll('.', '').replaceAll(',', '.')) == null) {
                              return 'Insira um valor válido';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone para contato',
                          hintText: '(11) 99999-9999',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.trim().isEmpty ? 'Contato é obrigatório' : null,
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Localização do anúncio',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),

                      if (context.watch<AddressController>().addresses.isNotEmpty) ...[
                        DropdownButtonFormField<Address?>(
                          initialValue: _isCreatingNewAddress ? null : _selectedSavedAddress,
                          decoration: const InputDecoration(
                            labelText: 'Selecione o Endereço',
                            prefixIcon: Icon(Icons.map_outlined),
                          ),
                          items: [
                            ...context.read<AddressController>().addresses.map((address) {
                              return DropdownMenuItem<Address?>(
                                value: address,
                                child: Text(address.alias ?? '${address.street}, ${address.number}'),
                              );
                            }),
                            const DropdownMenuItem<Address?>(
                              value: null,
                              child: Text('+ Cadastrar outro endereço...'),
                            ),
                          ],
                          onChanged: (address) {
                            setState(() {
                              if (address == null) {
                                _isCreatingNewAddress = true;
                                _selectedSavedAddress = null;
                              } else {
                                _isCreatingNewAddress = false;
                                _selectedSavedAddress = address;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (!_isCreatingNewAddress && _selectedSavedAddress != null) ...[
                        // Exibe um resumo do endereço selecionado
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.black54),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedSavedAddress!.formattedAddress,
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Campos manuais para novo endereço
                        TextFormField(
                          controller: _cepController,
                          decoration: InputDecoration(
                            labelText: 'CEP',
                            hintText: '00000-000',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            suffixIcon: _isLoadingCep 
                                ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87)))
                                : null,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: _onCepChanged,
                          validator: (value) {
                            if (!_isCreatingNewAddress) return null;
                            if (value == null || value.trim().isEmpty) return 'CEP é obrigatório';
                            if (value.replaceAll(RegExp(r'\D'), '').length != 8) return 'CEP deve ter 8 dígitos';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _streetController,
                          decoration: const InputDecoration(labelText: 'Rua / Logradouro'),
                          validator: (value) {
                            if (!_isCreatingNewAddress) return null;
                            return value!.trim().isEmpty ? 'Rua é obrigatória' : null;
                          },
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
                                validator: (value) {
                                  if (!_isCreatingNewAddress) return null;
                                  return value!.trim().isEmpty ? 'Número é obrigatório' : null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _complementController,
                                decoration: const InputDecoration(
                                  labelText: 'Complemento',
                                  hintText: 'Apto, Bloco, etc.',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _neighborhoodController,
                          decoration: const InputDecoration(labelText: 'Bairro'),
                          validator: (value) {
                            if (!_isCreatingNewAddress) return null;
                            return value!.trim().isEmpty ? 'Bairro é obrigatório' : null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _cityController,
                                decoration: const InputDecoration(labelText: 'Cidade'),
                                validator: (value) {
                                  if (!_isCreatingNewAddress) return null;
                                  return value!.trim().isEmpty ? 'Cidade é obrigatória' : null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _stateController,
                                decoration: const InputDecoration(labelText: 'UF'),
                                validator: (value) {
                                  if (!_isCreatingNewAddress) return null;
                                  return value!.trim().isEmpty ? 'UF obrigatória' : null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Checkbox para salvar em favoritos
                        CheckboxListTile(
                          title: const Text('Salvar este endereço nos meus favoritos', style: TextStyle(fontSize: 14)),
                          value: _saveToFavorites,
                          activeColor: Colors.black87,
                          onChanged: (bool? value) {
                            setState(() {
                              _saveToFavorites = value ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        
                        if (_saveToFavorites) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _addressAliasController,
                            decoration: const InputDecoration(
                              labelText: 'Apelido do Endereço (ex: Casa, Trabalho)',
                              hintText: 'Deixe em branco para salvar sem apelido',
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Publicar Anúncio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _addressAliasController.dispose();
    super.dispose();
  }
}
