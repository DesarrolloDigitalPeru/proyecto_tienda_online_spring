package com.tienda.controlador;

import com.tienda.modelo.Producto;
import com.tienda.modelo.Usuario;
import com.tienda.servicio.ProductoService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.stream.Collectors;

@Controller
public class ProductoController {

    @Autowired
    private ProductoService productoService;

    /**
     * Maneja las solicitudes GET para la página de productos (usuarios autenticados).
     * Permite filtrar productos por categoría y una cadena de búsqueda.
     */
    @GetMapping("/productos")
    public String verProductos(
            @RequestParam(value = "categoria", required = false) String categoria,
            @RequestParam(value = "search", required = false) String search,
            HttpSession session,
            Model model) {

        Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuario == null) {
            return "redirect:/login";
        }

        List<Producto> productos = productoService.findAllProductos();

        // Filtrar por categoría si se proporciona
        if (categoria != null && !categoria.isEmpty()) {
            productos = productos.stream()
                    .filter(p -> p.getCategoria() != null && p.getCategoria().name().equalsIgnoreCase(categoria))
                    .collect(Collectors.toList());
        }

        // Filtrar por búsqueda si se proporciona
        if (search != null && !search.isEmpty()) {
            String lowerCaseSearch = search.toLowerCase();
            productos = productos.stream()
                    .filter(p -> (p.getNombre() != null && p.getNombre().toLowerCase().contains(lowerCaseSearch)) ||
                                 (p.getDescripcion() != null && p.getDescripcion().toLowerCase().contains(lowerCaseSearch)) ||
                                 (p.getMarca() != null && p.getMarca().toLowerCase().contains(lowerCaseSearch)))
                    .collect(Collectors.toList());
        }

        model.addAttribute("productos", productos);
        model.addAttribute("categorias", Producto.CategoriaProducto.values());
        model.addAttribute("selectedCategoria", categoria);
        model.addAttribute("searchTerm", search);
        model.addAttribute("carritoCount", 0); // Por ahora sin carrito
        model.addAttribute("usuario", usuario);

        return "productos";
    }
}
