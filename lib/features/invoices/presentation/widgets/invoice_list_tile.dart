import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/invoice.dart';

/// List tile widget for displaying an invoice
///
/// Shows:
/// - Invoice number (factura)
/// - Date (formatted as dd/MM/yyyy)
/// - Total amount
/// - Base and IVA in subtitle
class InvoiceListTile extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;
  final VoidCallback? onDownloadPdf;
  final bool isDownloading;

  const InvoiceListTile({
    super.key,
    required this.invoice,
    this.onTap,
    this.onDownloadPdf,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            children: [
              // Invoice icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: AppConstants.spacingM),

              // Invoice details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Invoice number
                    Text(
                      invoice.factura,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: AppConstants.spacingXS),

                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          invoice.fechaFormatted,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.spacingXS),

                    // Base + IVA subtitle
                    Text(
                      'Base: ${invoice.baseImponibleFormatted} · IVA: ${invoice.importeIvaFormatted}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),

              // Total amount + download
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    invoice.importeTotalFormatted,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Download PDF button
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: isDownloading
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            tooltip: invoice.invoiceId != null
                                ? 'Ver PDF'
                                : 'PDF no disponible',
                            onPressed: invoice.invoiceId != null
                                ? onDownloadPdf
                                : null,
                            icon: Icon(
                              Icons.picture_as_pdf,
                              color: invoice.invoiceId != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
