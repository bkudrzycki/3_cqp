detach_packages <- function(packages) {
  invisible(lapply(packages, function(pkg) {
    # Try to unload the package with unloadNamespace()
    result <- tryCatch(
      expr = {
        unloadNamespace(pkg)
      },
      error = function(e) {
        NULL
      }
    )
    result
  }))
}