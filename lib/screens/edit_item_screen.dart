import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../controllers/item_controller.dart';
import '../widgets/image_source_sheet.dart';
import 'create_item_screen.dart'; // Para reutilizar CurrencyInputFormatter

class EditItemScreen extends StatefulWidget {
  final Item item;

  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _contactController;

  // Campos de Endereço
  late final TextEditingController _cepController;
  late final TextEditingController _streetController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _numberController;
  late final TextEditingController _complementController;

  bool _isLoadingCep = false;
  late String _selectedCondition;
  final List<String> _conditions = [
    'Novo',
    'Usado - Como novo',
    'Usado - Em bom estado',
    'Usado - Com marcas de uso',
    'Para Doação'
  ];

  late bool _isFree;
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    // Preenche com os dados existentes do anúncio
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController = TextEditingController(text: widget.item.description);
    _isFree = widget.item.isFree;
    
    // Formata o preço existente
    if (_isFree) {
      _priceController = TextEditingController();
    } else {
      final formattedPrice = widget.item.price.toStringAsFixed(2).replaceAll('.', ',');
      _priceController = TextEditingController(text: formattedPrice);
    }
    
    _contactController = TextEditingController(text: widget.item.contactInfo);
    _selectedCondition = widget.item.condition;

    _cepController = TextEditingController(text: widget.item.cep ?? '');
    _streetController = TextEditingController(text: widget.item.street ?? '');
    _neighborhoodController = TextEditingController(text: widget.item.neighborhood ?? '');
    _cityController = TextEditingController(text: widget.item.city ?? '');
    _stateController = TextEditingController(text: widget.item.state ?? '');
    _numberController = TextEditingController(text: widget.item.number ?? '');
    _complementController = TextEditingController(text: widget.item.complement ?? '');
  }

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
              _newImageFile = File(pickedFile.path);
            });
          }
        },
      ),
    );
  }

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
            const SnackBar(content: Text('CEP não encontrado ou inválido.'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao buscar o CEP.'), backgroundColor: Colors.red),
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

    final itemController = context.read<ItemController>();
    final double price = _isFree ? 0.0 : (double.tryParse(_priceController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0);

    final success = await itemController.updateItem(
      id: widget.item.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      condition: _selectedCondition,
      contactInfo: _contactController.text.trim(),
      imageFile: _newImageFile,
      existingImageUrl: widget.item.imageUrl,
      cep: _cepController.text.trim(),
      street: _streetController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      number: _numberController.text.trim(),
      complement: _complementController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anúncio atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${itemController.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Excluir Anúncio'),
          content: const Text('Tem certeza que deseja excluir permanentemente este anúncio? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final itemController = context.read<ItemController>();
                final success = await itemController.deleteItem(widget.item.id);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Anúncio excluído com sucesso!'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context, true); 
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: ${itemController.error}'), backgroundColor: Colors.red),
                  );
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
    final isLoading = context.select<ItemController, bool>((ctrl) => ctrl.isLoading);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9DB),
      appBar: AppBar(
        title: const Text('Editar Anúncio', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFFFF9DB),
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: isLoading ? null : _confirmDelete,
          ),
        ],
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
                      image: _newImageFile != null
                          ? DecorationImage(image: FileImage(_newImageFile!), fit: BoxFit.cover)
                          : (widget.item.imageUrl.isNotEmpty
                              ? DecorationImage(image: NetworkImage(widget.item.imageUrl), fit: BoxFit.cover)
                              : null),
                    ),
                    child: (_newImageFile == null && widget.item.imageUrl.isEmpty)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text('Adicionar fotos', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          )
                        : Container(
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.all(12),
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              radius: 18,
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
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
                        'Localização',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),

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
                      : const Text('Salvar Alterações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    super.dispose();
  }
}
