export function formatCurrency(value: number, minimumFractionDigits: number = 0): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits,
  }).format(value);
}
