% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/flash_set_conv_crit.R
\name{flash_set_conv_crit}
\alias{flash_set_conv_crit}
\title{Set convergence criterion and tolerance parameter}
\usage{
flash_set_conv_crit(flash, fn = NULL, tol)
}
\arguments{
\item{flash}{A \code{flash} or \code{flash_fit} object.}

\item{fn}{The convergence criterion function (see Details below). If
\code{NULL}, then only the tolerance parameter is updated (thus a
convergence criterion can be set at the beginning of a \code{flash} pipeline,
allowing the tolerance parameter to be updated at will without needing to
re-specify the convergence criterion each time). The default convergence
criterion, which is set when the \code{flash} object is initialized, is
\code{\link{flash_conv_crit_elbo_diff}}, which calculates the
difference in the variational lower bound or "ELBO" from one iteration to
the next.}

\item{tol}{The tolerance parameter (see Details below). The default, which is
set when the \code{flash} object is initialized (see
\code{\link{flash_init}}), is \eqn{np\sqrt{\epsilon}}, where \eqn{n} is the
number of rows in the dataset, \eqn{p} is the number of columns, and
\eqn{\epsilon} is equal to \code{\link{.Machine}$double.eps}.}
}
\value{
The \code{\link{flash}} object from argument \code{flash}, with the
new convergence criterion reflected in updates to the "internal"
\code{flash_fit} object. These settings will persist across
all subsequent calls to \code{flash_xxx} functions in the same
\code{flash} pipeline (unless, of course, \code{flash_set_conv_crit} is
again called within the same pipeline).
}
\description{
Used in a \code{\link{flash}} pipeline to set the criterion for
determining whether a greedy fit or backfit has "converged."
}
\details{
Function \code{flash_set_conv_crit} can be used to customize
the convergence criterion for a \code{flash} object. This criterion
determines when to stop optimizing a newly added factor
(see \code{\link{flash_greedy}}) and when to stop backfitting
(\code{\link{flash_backfit}}). Note that, because most alternative
convergence criteria do not make sense in the context of a nullcheck, it
does not set the "convergence" criterion for \code{\link{flash_nullcheck}}
(for example, \code{\link{flash_conv_crit_max_chg_L}} would simply return
the maximum \eqn{L^2}-normalized loading for each set of loadings
\eqn{\ell_{\cdot k}}).

The criterion is defined by the function supplied as argument to \code{fn},
which must accept exactly three parameters,
\code{curr}, \code{prev}, and \code{k}. \code{curr} refers to the
\code{\link{flash_fit}} object from the current iteration; \code{prev},
to the \code{flash_fit} object from the previous iteration;
and, if the iteration is a sequential backfitting iteration (that is, a
\code{\link{flash_backfit}} iteration with argument
\code{extrapolate = FALSE}), \code{k} identifies the factor/loadings pair
that is currently being updated (in all other cases, \code{k} is
\code{NULL}). The function must output a numeric value; if the value is
less than or equal to \code{tol}, then the fit is considered to have
"converged." The meaning of "convergence" here varies according to the
operation being performed.
In the greedy algorithm, \code{fn} simply compares the fit from
one iteration to the next. During a backfit, it similarly compares fits from
one iteration to the next, but it only considers the fit to have
converged when the value of \code{fn} over successive updates to
\emph{all} factor/loadings pairs is less than or equal to \code{tol}. If,
for example, factor/loadings pairs \eqn{1, \ldots, K} are being
sequentially backfitted, then fits are compared before and
after the update to factor/loadings 1, before and after the update to
factor/loadings 2, and so on through factor/loadings \eqn{K},
and backfitting only terminates when \code{fn} returns a value less
than or equal to \code{tol} for all \eqn{K} updates.

Package \code{flashier} provides a number of functions that may be supplied
as convergence criteria: see
\code{\link{flash_conv_crit_elbo_diff}} (the default criterion),
\code{\link{flash_conv_crit_max_chg}},
\code{\link{flash_conv_crit_max_chg_L}}, and
\code{\link{flash_conv_crit_max_chg_F}}. Custom functions may also be
defined. Typically, they will compare the fit in \code{curr} (the current
iteration) to the fit in \code{prev} (the previous iteration).
To facilitate working with \code{flash_fit} objects, package
\code{flashier} provides a number of accessors, which are enumerated in
the documentation for object \code{\link{flash_fit}}. Custom functions
should return a numeric value that can be compared against \code{tol}; see
\strong{Examples} below.
}
\examples{
fl <- flash_init(gtex) |>
  flash_set_conv_crit(flash_conv_crit_max_chg, tol = 1e-3) |>
  flash_set_verbose(
    verbose = 3,
    fns = flash_verbose_max_chg,
    colnames = "Max Chg",
    colwidths = 20
  ) |>
  flash_greedy(Kmax = 3)

}
