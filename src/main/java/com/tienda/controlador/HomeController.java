package com.tienda.controlador;

import com.tienda.modelo.Producto;
import com.tienda.modelo.Usuario;
import com.tienda.servicio.ProductoService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Controller
public class HomeController {

    @Autowired
    private ProductoService productoService;

    @GetMapping("/")
    public String home(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuario != null) {
            return "redirect:/bienvenida";
        }
        return "redirect:/login";
    }

    @GetMapping("/bienvenida")
    public String bienvenida(HttpSession session, Model model) {
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuario == null) {
            return "redirect:/login";
        }

        // Obtener productos en oferta (con descuento > 0)
        List<Producto> productosEnOferta = productoService.findAllProductos().stream()
                .filter(p -> p.getDescuento() != null && p.getDescuento().compareTo(BigDecimal.ZERO) > 0)
                .collect(Collectors.toList());

        model.addAttribute("usuario", usuario);
        model.addAttribute("carritoCount", 0); // Por ahora sin carrito
        model.addAttribute("productosEnOferta", productosEnOferta);

        return "bienvenida";
    }
}
