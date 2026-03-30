import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_application_1/services/almacen_service.dart';
import 'package:flutter_application_1/services/categoria_service.dart';
import 'package:flutter_application_1/models/almacen_model.dart';
import 'package:flutter_application_1/models/categoria_model.dart';

class AgregarProductoUI extends StatefulWidget {
  final VoidCallback onProductoAgregado;
  final Producto? producto;

  const AgregarProductoUI({
    super.key,
    required this.onProductoAgregado,
    this.producto,
  });

  @override
  State<AgregarProductoUI> createState() => _AgregarProductoUIState();
}

class _AgregarProductoUIState extends State<AgregarProductoUI> {
  late TextEditingController _nombreController;
  late TextEditingController _codigoController;
  late TextEditingController _cantidadController;
  late TextEditingController _precioController;
  late TextEditingController _grosorController;
  late TextEditingController _descripcionController;

  String? _categoriaSeleccionada;
  List<Categoria> _categorias = [];
  bool _cargandoCategorias = false;
  Uint8List? _imagenBytes;
  String? _imagenFilename;
  bool _cargando = false;
  bool _editing = false;
  String? _productId;

  final AlmacenService _almacenService = AlmacenService();
  final CategoriaService _categoriaService = CategoriaService();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _codigoController = TextEditingController();
    _cantidadController = TextEditingController(text: '1');
    _precioController = TextEditingController();
    _grosorController = TextEditingController();
    _descripcionController = TextEditingController();
    _categoriaSeleccionada = null;
    // si hay producto, entrar en modo edición y rellenar campos
    if (widget.producto != null) {
      _editing = true;
      final p = widget.producto!;
      _productId = p.id;
      _nombreController.text = p.nombre;
      _codigoController.text = p.codigo ?? '';
      _cantidadController.text = (p.cantidad ?? 1).toString();
      _precioController.text = p.precio != null ? p.precio.toString() : '';
      _grosorController.text = p.grosor ?? '';
      _descripcionController.text = p.descripcion ?? '';
      // Nota: _categoriaSeleccionada se establece después de cargar categorías
      // imagen is shown from URL when editing; user can choose new one
    }
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    setState(() => _cargandoCategorias = true);
    final cats = await _categoriaService.obtenerCategorias();
    // ignore: avoid_print
    print('categorias recibidas: $cats');
    if (cats.isNotEmpty) {
      setState(() {
        _categorias = cats;
        // Si estamos en modo edición, ahora establecer la categoría correcta
        if (_editing && widget.producto != null) {
          final categoriaId = widget.producto!.categoriaId;
          if (categoriaId != null && cats.any((c) => c.id == categoriaId)) {
            _categoriaSeleccionada = categoriaId;
          } else {
            _categoriaSeleccionada = null;
          }
        }
      });
    } else {
      // si falla la obtención, mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudieron cargar categorías')),
        );
      }
    }
    setState(() => _cargandoCategorias = false);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    _grosorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes != null) {
        setState(() {
          _imagenBytes = bytes;
          _imagenFilename = file.name;
        });
      }
    }
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imagenBytes = bytes;
        _imagenFilename = pickedFile.name;
      });
    }
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _codigoController.clear();
    _cantidadController.text = '1';
    _precioController.clear();
    _grosorController.clear();
    _descripcionController.clear();
    setState(() {
      _categoriaSeleccionada = null;
      _imagenBytes = null;
      _imagenFilename = null;
    });
  }

  Future<void> _agregarProducto() async {
    final nombre = _nombreController.text.trim();
    final codigo = _codigoController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final grosor = _grosorController.text.trim();

    if (nombre.isEmpty) {
      _snack("Ingresa el nombre del producto");
      return;
    }

    if (_precioController.text.isEmpty) {
      _snack("Ingresa el precio");
      return;
    }

    setState(() => _cargando = true);

    try {
      if (codigo.isNotEmpty) {
        final existeCodigo = await _almacenService.existeCodigoProducto(
          codigo,
          excluirProductoId: _editing ? _productId : null,
        );
        if (existeCodigo) {
          _snack('El codigo "$codigo" ya existe. Usa otro codigo.');
          return;
        }
      }

      final request = CrearProductoRequest(
        nombre: nombre,
        descripcion: descripcion.isEmpty ? null : descripcion,
        categoriaId: _categoriaSeleccionada,
        precio: double.tryParse(_precioController.text) ?? 0,
        cantidad: int.tryParse(_cantidadController.text) ?? 1,
        codigo: codigo.isEmpty ? null : codigo,
        grosor: grosor.isEmpty ? null : grosor,
      );
      if (_editing && _productId != null) {
        final resp = await _almacenService.actualizarProductoConImagen(
          _productId!,
          request,
          imageBytes: _imagenBytes,
          filename: _imagenFilename,
        );

        if (resp.success) {
          widget.onProductoAgregado();
          _snack("Producto actualizado correctamente");
          // si venimos por navegación, volver con true
          if (Navigator.canPop(context)) Navigator.of(context).pop(true);
        } else {
          _snack("Error al actualizar producto: ${resp.message}");
        }
      } else {
        final resp = await _almacenService.crearProducto(
          request,
          imageBytes: _imagenBytes,
          filename: _imagenFilename,
        );

        if (resp.success) {
          _limpiarFormulario();
          widget.onProductoAgregado();
          _snack("Producto agregado correctamente");
        } else {
          _snack("Error al agregar producto: ${resp.message}");
        }
      }
    } catch (e) {
      _snack("Error al agregar producto");
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editing;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF9D2612),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'EDITAR PRODUCTO' : 'NUEVO PRODUCTO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEditing
                              ? 'Modifica los datos del producto'
                              : 'Completa los datos para registrar',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Formulario ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    // Sección imagen (arriba, grande)
                    _SeccionImagen(
                      imagenBytes: _imagenBytes,
                      imagenUrl: isEditing ? widget.producto?.imagen : null,
                      onGaleria: _seleccionarImagen,
                      onCamara: _tomarFoto,
                    ),

                    const SizedBox(height: 16),

                    // Sección datos principales
                    _Seccion(
                      titulo: 'Información del producto',
                      icono: Icons.info_outline,
                      children: [
                        _Campo(
                          label: 'Nombre del Producto *',
                          hint: 'Ej. Vidrio Templado',
                          controller: _nombreController,
                          icono: Icons.label_outline,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _Campo(
                                label: 'Código',
                                hint: 'VT-001',
                                controller: _codigoController,
                                icono: Icons.qr_code,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _Campo(
                                label: 'Grosor',
                                hint: 'Ej. 6mm',
                                controller: _grosorController,
                                icono: Icons.straighten,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _Campo(
                                label: 'Cantidad *',
                                hint: '1',
                                controller: _cantidadController,
                                icono: Icons.numbers,
                                tipo: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _Campo(
                                label: 'Precio Unit. *',
                                hint: '0.00',
                                controller: _precioController,
                                icono: Icons.attach_money,
                                tipo: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Sección categoría
                    _Seccion(
                      titulo: 'Clasificación',
                      icono: Icons.category_outlined,
                      children: [_dropdown()],
                    ),

                    const SizedBox(height: 14),

                    // Sección descripción
                    _Seccion(
                      titulo: 'Descripción',
                      icono: Icons.notes,
                      children: [
                        _Campo(
                          label: 'Descripción (opcional)',
                          hint: 'Escribe una descripción...',
                          controller: _descripcionController,
                          icono: Icons.text_fields,
                          maxLines: 3,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Botones
                    Row(
                      children: [
                        // Limpiar (solo en modo crear)
                        if (!isEditing) ...[
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: _limpiarFormulario,
                              icon: const Icon(
                                Icons.refresh,
                                color: Color(0xFF9D2612),
                              ),
                              label: const Text(
                                'Limpiar',
                                style: TextStyle(color: Color(0xFF9D2612)),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF9D2612),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: _cargando ? null : _agregarProducto,
                            icon: _cargando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    isEditing
                                        ? Icons.save_outlined
                                        : Icons.add_circle_outline,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              isEditing ? 'Guardar cambios' : 'Agregar',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9D2612),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE3EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _categoriaSeleccionada,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Color(0xFF9D2612)),
          hint: const Text(
            'Seleccionar categoría',
            style: TextStyle(color: Colors.grey),
          ),
          items: [
            if (_cargandoCategorias)
              const DropdownMenuItem(value: '', child: Text('Cargando...'))
            else
              ..._categorias.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Text(c.descripcion),
                );
              }).toList(),
          ],
          onChanged: (v) => setState(() => _categoriaSeleccionada = v),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    required this.icono,
    required this.children,
  });

  final String titulo;
  final IconData icono;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 16, color: const Color(0xFF9D2612)),
              const SizedBox(width: 6),
              Text(
                titulo.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9D2612),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEF1F5)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icono,
    this.tipo = TextInputType.text,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icono;
  final TextInputType tipo;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: tipo,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0BAC9), fontSize: 13),
            prefixIcon: Icon(icono, size: 18, color: const Color(0xFF9D2612)),
            filled: true,
            fillColor: const Color(0xFFF7F9FC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF9D2612),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SeccionImagen extends StatelessWidget {
  const _SeccionImagen({
    required this.imagenBytes,
    required this.imagenUrl,
    required this.onGaleria,
    required this.onCamara,
  });

  final Uint8List? imagenBytes;
  final String? imagenUrl;
  final VoidCallback onGaleria;
  final VoidCallback onCamara;

  @override
  Widget build(BuildContext context) {
    final bool tieneImagen = imagenBytes != null || imagenUrl != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Área de previsualización / placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: tieneImagen
                ? Stack(
                    children: [
                      imagenBytes != null
                          ? Image.memory(
                              imagenBytes!,
                              width: double.infinity,
                              height: 190,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              imagenUrl!,
                              width: double.infinity,
                              height: 190,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            ),
                      // Overlay etiqueta
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          color: Colors.black.withOpacity(0.4),
                          child: const Text(
                            'Imagen del producto',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : _placeholder(),
          ),

          // Botones galería / cámara
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _BtnImagen(
                    icono: Icons.image_outlined,
                    texto: 'Galería',
                    onTap: onGaleria,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _BtnImagen(
                    icono: Icons.camera_alt_outlined,
                    texto: 'Cámara',
                    onTap: onCamara,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 160,
      color: const Color(0xFFF4F6F9),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 44,
            color: Color(0xFFBBCCDA),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega una foto del producto',
            style: TextStyle(color: Color(0xFFAABDCC), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BtnImagen extends StatelessWidget {
  const _BtnImagen({
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF9D2612).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF9D2612).withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 18, color: const Color(0xFF9D2612)),
            const SizedBox(width: 6),
            Text(
              texto,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9D2612),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
